#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:?usage: bash healthcheck.sh /mnt/data/code/models/<name>.env}"
source "$CONFIG_FILE"

LOG_DIR=/mnt/data/logs/teacher_service
mkdir -p "$LOG_DIR"

echo "== Checking model list (port: $PORT) =="

curl -s http://127.0.0.1:${PORT}/v1/models \
  -H "Authorization: Bearer ${API_KEY:-teacher-local}" \
  | tee "${LOG_DIR}/${SERVED_MODEL_NAME}_models.json"

echo
echo "== Liveness (GET /health) =="
curl -sf "http://127.0.0.1:${PORT}/health" >/dev/null
echo "ok"

# Chat smoke test: some stacks (e.g. Mistral + MistralCommonTokenizer) reject
# server-injected chat_template kwargs like reasoning_effort — skip via env.
HEALTHCHECK_CHAT_COMPLETIONS="${HEALTHCHECK_CHAT_COMPLETIONS:-1}"
echo
if [[ "$HEALTHCHECK_CHAT_COMPLETIONS" == "1" ]]; then
  echo "== Sending test request (chat completions) =="
  curl -s http://127.0.0.1:${PORT}/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${API_KEY:-teacher-local}" \
    -d "{
      \"model\": \"${SERVED_MODEL_NAME}\",
      \"messages\": [
        {\"role\": \"user\", \"content\": \"What is 1+1?\"}
      ],
      \"temperature\": 0.2,
      \"max_tokens\": 128
    }" \
    | tee "${LOG_DIR}/${SERVED_MODEL_NAME}_healthcheck.json"
else
  echo "== Chat smoke test skipped (HEALTHCHECK_CHAT_COMPLETIONS=${HEALTHCHECK_CHAT_COMPLETIONS}) =="
  printf '%s\n' '{"skipped":true,"reason":"HEALTHCHECK_CHAT_COMPLETIONS disabled; models list + /health passed"}' \
    | tee "${LOG_DIR}/${SERVED_MODEL_NAME}_healthcheck.json"
fi

echo
echo "== Done =="
echo "Saved to:"
echo "  ${LOG_DIR}/${SERVED_MODEL_NAME}_models.json"
echo "  ${LOG_DIR}/${SERVED_MODEL_NAME}_healthcheck.json"