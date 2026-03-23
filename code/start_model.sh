#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:?usage: bash /mnt/data/code/start_model.sh /mnt/data/code/models/<name>.env}"
source "$CONFIG_FILE"

mkdir -p /mnt/data/logs/teacher_service

nohup bash /mnt/data/code/serve_model_front.sh "$CONFIG_FILE" \
  > "/mnt/data/logs/teacher_service/${SERVED_MODEL_NAME}.log" 2>&1 &

echo $! > "/mnt/data/logs/teacher_service/${SERVED_MODEL_NAME}.pid"
echo "PID: $(cat /mnt/data/logs/teacher_service/${SERVED_MODEL_NAME}.pid)"
echo "LOG: /mnt/data/logs/teacher_service/${SERVED_MODEL_NAME}.log"
