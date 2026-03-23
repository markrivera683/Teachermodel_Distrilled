#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:?usage: bash /mnt/data/code/serve_model.sh /mnt/data/code/models/<name>.env}"
source "$CONFIG_FILE"

source /root/venvs/teacher-vllm/bin/activate

export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0,1,2,3,4,5,6,7}"
export HF_HOME="${HF_HOME:-/mnt/data/cache/hf}"
export VLLM_WORKER_MULTIPROC_METHOD=spawn

mkdir -p /mnt/data/logs/teacher_service

vllm serve "$MODEL_PATH" \
  --served-model-name "$SERVED_MODEL_NAME" \
  --host 0.0.0.0 \
  --port "$PORT" \
  --tensor-parallel-size "$TP_SIZE" \
  --dtype "${DTYPE:-auto}" \
  --api-key "${API_KEY:-teacher-local}" \
  --generation-config "${GEN_CONFIG:-vllm}"