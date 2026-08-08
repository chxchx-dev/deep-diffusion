#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/configs/default.env"
BACKEND="${BACKEND_OVERRIDE:-${BACKEND}}"
WIDTH="${WIDTH_OVERRIDE:-${WIDTH}}"
HEIGHT="${HEIGHT_OVERRIDE:-${HEIGHT}}"
STEPS="${STEPS_OVERRIDE:-${STEPS}}"
CFG_SCALE="${CFG_SCALE_OVERRIDE:-${CFG_SCALE}}"
SEED="${SEED_OVERRIDE:-${SEED}}"
SAMPLING_METHOD="${SAMPLING_METHOD:-euler_a}"
LORA_APPLY_MODE="${LORA_APPLY_MODE:-immediately}"
VAE_TILING="${VAE_TILING:-1}"
BENCHMARK_TAG="${BENCHMARK_TAG:-default}"
ENGINE="${ROOT_DIR}/vendor/stable-diffusion.cpp/build/bin/sd-cli"
OUTPUT="${ROOT_DIR}/outputs/benchmark-$(date +%Y%m%d-%H%M%S).png"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${LOG_DIR}"

if [[ ! -x "${ENGINE}" || ! -f "${ROOT_DIR}/${MODEL}" ]]; then
  echo "Falta el motor o el modelo." >&2
  exit 1
fi

LOG_FILE="${LOG_DIR}/benchmark-${BENCHMARK_TAG}-$(date +%Y%m%d-%H%M%S).txt"
{
  echo "deep-n benchmark"
  echo "tag=${BENCHMARK_TAG}"
  date --iso-8601=seconds
  echo "model=${MODEL}"
  echo "resolution=${WIDTH}x${HEIGHT} steps=${STEPS} seed=${SEED} sampling_method=${SAMPLING_METHOD}"
  ENGINE_ARGS=(
    -m "${ROOT_DIR}/${MODEL}"
    -p "a red apple on a wooden table, studio lighting, detailed"
    -o "${OUTPUT}"
    -W "${WIDTH}" -H "${HEIGHT}"
    --steps "${STEPS}" --cfg-scale "${CFG_SCALE}" --seed "${SEED}"
    --sampling-method "${SAMPLING_METHOD}"
    --lora-model-dir "${ROOT_DIR}/${LORA_DIR}"
    --lora-apply-mode "${LORA_APPLY_MODE}"
    --backend "${BACKEND}"
  )
  if [[ "${VAE_TILING}" == "1" ]]; then
    ENGINE_ARGS+=(--vae-tiling)
  fi
  /usr/bin/time -v "${ENGINE}" "${ENGINE_ARGS[@]}"
} 2>&1 | tee "${LOG_FILE}"

echo "Benchmark guardado en: ${LOG_FILE}"
