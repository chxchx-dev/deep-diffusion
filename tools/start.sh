#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL="${MODEL_OVERRIDE:-models/v1-5-pruned-emaonly.safetensors}"
if [[ "${MODEL}" != /* ]]; then
  MODEL_PATH="${ROOT_DIR}/${MODEL}"
else
  MODEL_PATH="${MODEL}"
fi

if [[ ! -d "${ROOT_DIR}/web/node_modules" ]]; then
  echo "Faltan dependencias web. Ejecuta: pnpm run install" >&2
  exit 1
fi
if [[ ! -f "${ROOT_DIR}/web/dist/index.html" ]]; then
  echo "Falta el frontend compilado. Ejecuta: pnpm run build" >&2
  exit 1
fi
if [[ ! -f "${MODEL_PATH}" ]]; then
  echo "No existe el modelo: ${MODEL_PATH}" >&2
  exit 1
fi

echo "Iniciando deep-diffusion con React + backend local..."
echo "Frontend y API: http://127.0.0.1:1234"
echo "Modelo inicial: ${MODEL_PATH}"
echo "Detener: Ctrl+C"
exec "${ROOT_DIR}/tools/run-web.sh"
