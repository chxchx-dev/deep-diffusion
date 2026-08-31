#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/configs/default.env"
MODEL="${MODEL_OVERRIDE:-${MODEL}}"
SERVER="${ROOT_DIR}/vendor/stable-diffusion.cpp/build/bin/sd-server"
if [[ "${MODEL}" != /* ]]; then
  MODEL="${ROOT_DIR}/${MODEL}"
fi
FRONTEND="${ROOT_DIR}/web/dist/index.html"
SUPERVISOR="${ROOT_DIR}/tools/model-supervisor.py"
BACKEND="${BACKEND_OVERRIDE:-${BACKEND}}"
LORA_APPLY_MODE="${LORA_APPLY_MODE:-immediately}"
VAE_TILING="${VAE_TILING:-1}"

if [[ ! -x "${SERVER}" || ! -x "${SUPERVISOR}" ]]; then
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

exec python3 "${SUPERVISOR}" \
  --root "${ROOT_DIR}" \
  --server "${SERVER}" \
  --model "${MODEL}" \
  --frontend "web/dist/index.html" \
  --lora-dir "${LORA_DIR}" \
  --lora-apply-mode "${LORA_APPLY_MODE}" \
  --backend "${BACKEND}" \
  --vae-tiling "${VAE_TILING}"
