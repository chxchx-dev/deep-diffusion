#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${ROOT_DIR}/configs/default.env"
ENGINE="${ROOT_DIR}/vendor/stable-diffusion.cpp/build/bin/sd-cli"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "No existe la configuración: ${CONFIG_FILE}" >&2
  exit 1
fi
source "${CONFIG_FILE}"

BACKEND="${BACKEND_OVERRIDE:-${BACKEND}}"
NEGATIVE_PROMPT="${NEGATIVE_PROMPT:-}"
SAMPLING_METHOD="${SAMPLING_METHOD:-euler_a}"
LORA_APPLY_MODE="${LORA_APPLY_MODE:-immediately}"
VAE_TILING="${VAE_TILING:-1}"
WIDTH="${WIDTH_OVERRIDE:-${WIDTH}}"
HEIGHT="${HEIGHT_OVERRIDE:-${HEIGHT}}"
STEPS="${STEPS_OVERRIDE:-${STEPS}}"
CFG_SCALE="${CFG_SCALE_OVERRIDE:-${CFG_SCALE}}"
SEED="${SEED_OVERRIDE:-${SEED}}"
STRENGTH="${STRENGTH_OVERRIDE:-0.75}"

MODE="${1:-}"
INPUT="${2:-}"
MASK=""
PROMPT=""
if [[ "${MODE}" == "inpaint" ]]; then
  MASK="${3:-}"
  PROMPT="${4:-}"
else
  PROMPT="${3:-}"
fi

if [[ "${MODE}" != "img2img" && "${MODE}" != "inpaint" ]]; then
  echo "Uso: $0 img2img IMAGEN PROMPT" >&2
  echo "     $0 inpaint IMAGEN MASCARA PROMPT" >&2
  exit 2
fi
if [[ -z "${INPUT}" || ! -f "${ROOT_DIR}/${INPUT}" && ! -f "${INPUT}" ]]; then
  echo "No existe la imagen de entrada: ${INPUT}" >&2
  exit 1
fi
if [[ "${MODE}" == "inpaint" && ( -z "${MASK}" || ! -f "${ROOT_DIR}/${MASK}" && ! -f "${MASK}" ) ]]; then
  echo "No existe la máscara: ${MASK}" >&2
  exit 1
fi
if [[ -z "${PROMPT}" ]]; then
  echo "El prompt no puede estar vacío." >&2
  exit 2
fi
if [[ ! -x "${ENGINE}" ]]; then
  echo "No existe el ejecutable: ${ENGINE}" >&2
  exit 1
fi
if [[ ! -f "${ROOT_DIR}/${MODEL}" ]]; then
  echo "No existe el modelo: ${ROOT_DIR}/${MODEL}" >&2
  exit 1
fi

resolve_path() {
  if [[ -f "$1" ]]; then
    printf '%s' "$1"
  else
    printf '%s/%s' "${ROOT_DIR}" "$1"
  fi
}

INPUT_PATH="$(resolve_path "${INPUT}")"
MASK_PATH=""
if [[ "${MODE}" == "inpaint" ]]; then
  MASK_PATH="$(resolve_path "${MASK}")"
fi
STAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT="${ROOT_DIR}/${OUTPUT_DIR}/${MODE}-${STAMP}.png"
METADATA="${OUTPUT%.png}.json"
STARTED_AT="$(date +%s)"
mkdir -p "${ROOT_DIR}/${OUTPUT_DIR}"

ENGINE_ARGS=(
  -m "${ROOT_DIR}/${MODEL}"
  -p "${PROMPT}"
  -i "${INPUT_PATH}"
  -o "${OUTPUT}"
  -W "${WIDTH}" -H "${HEIGHT}"
  --steps "${STEPS}"
  --cfg-scale "${CFG_SCALE}"
  --seed "${SEED}"
  --sampling-method "${SAMPLING_METHOD}"
  --lora-model-dir "${ROOT_DIR}/${LORA_DIR}"
  --lora-apply-mode "${LORA_APPLY_MODE}"
  --strength "${STRENGTH}"
  --backend "${BACKEND}"
)
if [[ -n "${NEGATIVE_PROMPT}" ]]; then
  ENGINE_ARGS+=(--negative-prompt "${NEGATIVE_PROMPT}")
fi
if [[ "${MODE}" == "inpaint" ]]; then
  ENGINE_ARGS+=(--mask "${MASK_PATH}")
fi
if [[ "${VAE_TILING}" == "1" ]]; then
  ENGINE_ARGS+=(--vae-tiling)
fi

echo "Ejecutando ${MODE} con backend: ${BACKEND}"
"${ENGINE}" "${ENGINE_ARGS[@]}"
FINISHED_AT="$(date +%s)"
DURATION_SECONDS=$((FINISHED_AT - STARTED_AT))
MODEL_SHA256="$(sha256sum "${ROOT_DIR}/${MODEL}" | awk '{print $1}')"
ENGINE_HELP="$("${ENGINE}" --help 2>&1)"
ENGINE_VERSION="$(printf '%s\\n' "${ENGINE_HELP}" | sed -n '1p' | awk '{print $NF}')"

python3 - "${METADATA}" "${ROOT_DIR}" "${MODE}" "${INPUT}" "${MASK}" "${MODEL}" "${MODEL_SHA256}" "${ENGINE_VERSION}" "${PROMPT}" "${NEGATIVE_PROMPT}" "${OUTPUT}" "${WIDTH}" "${HEIGHT}" "${STEPS}" "${CFG_SCALE}" "${SEED}" "${SAMPLING_METHOD}" "${STRENGTH}" "${BACKEND}" "${DURATION_SECONDS}" <<'PY'
import csv
import json
import platform
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

(metadata_path, root, mode, input_path, mask_path, model, model_sha256,
 engine_version, prompt, negative_prompt, output, width, height, steps, cfg,
 seed, sampling_method, strength, backend, duration_seconds) = sys.argv[1:]
payload = {
    "created_at": datetime.now(timezone.utc).isoformat(),
    "project": "deep-n",
    "mode": mode,
    "input": input_path,
    "mask": mask_path or None,
    "model": model,
    "model_sha256": model_sha256,
    "engine_version": engine_version,
    "prompt": prompt,
    "loras": [
        {"name": name, "weight": float(weight)}
        for name, weight in re.findall(r"<lora:([^:>]+):([^>]+)>", prompt)
    ],
    "negative_prompt": negative_prompt,
    "output": str(Path(output).relative_to(root)),
    "width": int(width),
    "height": int(height),
    "steps": int(steps),
    "cfg_scale": float(cfg),
    "seed": int(seed),
    "sampling_method": sampling_method,
    "strength": float(strength),
    "backend": backend,
    "duration_seconds": int(duration_seconds),
    "platform": platform.platform(),
}
Path(metadata_path).write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
registry = Path(root) / "experiments" / "registry.csv"
with registry.open("a", newline="", encoding="utf-8") as handle:
    csv.writer(handle).writerow([
        payload["created_at"], payload["output"], payload["model"], payload["prompt"],
        payload["width"], payload["height"], payload["steps"], payload["cfg_scale"],
        payload["seed"], payload["backend"], payload["model_sha256"],
        payload["engine_version"], payload["negative_prompt"], payload["sampling_method"],
        payload["duration_seconds"], f"mode={mode};input={input_path};mask={mask_path}",
    ])
print(f"Metadatos: {metadata_path}")
print(f"Registro: {registry}")
PY
