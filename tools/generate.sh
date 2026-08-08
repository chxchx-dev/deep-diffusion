#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${CONFIG_FILE_OVERRIDE:-${ROOT_DIR}/configs/default.env}"
ENGINE="${ROOT_DIR}/vendor/stable-diffusion.cpp/build/bin/sd-cli"

if [[ "${CONFIG_FILE}" != /* ]]; then
  CONFIG_FILE="${ROOT_DIR}/${CONFIG_FILE}"
fi

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

if [[ ! -x "${ENGINE}" ]]; then
  echo "No existe el ejecutable: ${ENGINE}" >&2
  exit 1
fi
if [[ ! -f "${ROOT_DIR}/${MODEL}" ]]; then
  echo "No existe el modelo: ${ROOT_DIR}/${MODEL}" >&2
  exit 1
fi

PROMPT="${*:-a cozy cabin in a misty pine forest, cinematic lighting, detailed}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT="${ROOT_DIR}/${OUTPUT_DIR}/generation-${STAMP}.png"
METADATA="${OUTPUT%.png}.json"
STARTED_AT="$(date +%s)"

mkdir -p "${ROOT_DIR}/${OUTPUT_DIR}"
echo "Generando con backend: ${BACKEND}"
echo "Prompt: ${PROMPT}"
echo "Salida: ${OUTPUT}"

ENGINE_ARGS=(
  -m "${ROOT_DIR}/${MODEL}"
  -p "${PROMPT}"
  -o "${OUTPUT}"
  -W "${WIDTH}" -H "${HEIGHT}"
  --steps "${STEPS}"
  --cfg-scale "${CFG_SCALE}"
  --seed "${SEED}"
  --sampling-method "${SAMPLING_METHOD}"
  --lora-model-dir "${ROOT_DIR}/${LORA_DIR}"
  --lora-apply-mode "${LORA_APPLY_MODE}"
  --backend "${BACKEND}"
)
if [[ -n "${NEGATIVE_PROMPT}" ]]; then
  ENGINE_ARGS+=(--negative-prompt "${NEGATIVE_PROMPT}")
fi
if [[ "${VAE_TILING}" == "1" ]]; then
  ENGINE_ARGS+=(--vae-tiling)
fi

"${ENGINE}" "${ENGINE_ARGS[@]}"
FINISHED_AT="$(date +%s)"
DURATION_SECONDS=$((FINISHED_AT - STARTED_AT))
MODEL_SHA256="$(sha256sum "${ROOT_DIR}/${MODEL}" | awk '{print $1}')"
ENGINE_HELP="$("${ENGINE}" --help 2>&1)"
ENGINE_VERSION="$(printf '%s\\n' "${ENGINE_HELP}" | sed -n '1p' | awk '{print $NF}')"

python3 - "${METADATA}" "${ROOT_DIR}" "${MODEL}" "${MODEL_SHA256}" "${ENGINE_VERSION}" "${PROMPT}" "${NEGATIVE_PROMPT}" "${OUTPUT}" "${WIDTH}" "${HEIGHT}" "${STEPS}" "${CFG_SCALE}" "${SEED}" "${SAMPLING_METHOD}" "${BACKEND}" "${DURATION_SECONDS}" <<'PY'
import csv
import json
import platform
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

(metadata_path, root, model, model_sha256, engine_version, prompt, negative_prompt,
 output, width, height, steps, cfg, seed, sampling_method, backend,
 duration_seconds) = sys.argv[1:]
payload = {
    "created_at": datetime.now(timezone.utc).isoformat(),
    "project": "deep-n",
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
        payload["duration_seconds"], "",
    ])
print(f"Metadatos: {metadata_path}")
print(f"Registro: {registry}")
PY
