#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/configs/default.env"
SERVER="${ROOT_DIR}/vendor/stable-diffusion.cpp/build/bin/sd-server"
MODEL="${ROOT_DIR}/${MODEL}"
FRONTEND="${ROOT_DIR}/web/dist/index.html"
BACKEND="${BACKEND_OVERRIDE:-${BACKEND}}"
LORA_APPLY_MODE="${LORA_APPLY_MODE:-immediately}"
VAE_TILING="${VAE_TILING:-1}"

if [[ ! -x "${SERVER}" ]]; then
  echo "Falta sd-server. Ejecuta: ninja -C vendor/stable-diffusion.cpp/build -j1 sd-server" >&2
  exit 1
fi
if [[ ! -f "${MODEL}" ]]; then
  echo "Falta el modelo SD 1.5." >&2
  exit 1
fi
if [[ ! -f "${FRONTEND}" ]]; then
  echo "Falta el frontend compilado: ${FRONTEND}" >&2
  exit 1
fi

echo "Interfaz local: http://127.0.0.1:1234"
echo "Detener: Ctrl+C"
SERVER_ARGS=(
  --model "${MODEL}" \
  --listen-ip 127.0.0.1 \
  --listen-port 1234 \
  --lora-model-dir "${ROOT_DIR}/${LORA_DIR}" \
  --lora-apply-mode "${LORA_APPLY_MODE}" \
  --serve-html-path "${FRONTEND}" \
  --backend "${BACKEND}"
)
if [[ "${VAE_TILING}" == "1" ]]; then
  SERVER_ARGS+=(--vae-tiling)
fi
exec "${SERVER}" "${SERVER_ARGS[@]}"
