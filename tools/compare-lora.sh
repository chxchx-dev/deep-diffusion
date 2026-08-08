#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT="watercolor painting, a red apple on a wooden table, studio lighting, detailed"

for weight in 0.4 0.6 0.8; do
  echo "=== LoRA weight ${weight} ==="
  WIDTH_OVERRIDE=512 HEIGHT_OVERRIDE=512 STEPS_OVERRIDE=20 \
    "${ROOT_DIR}/tools/generate.sh" \
    "<lora:fladdict-watercolor-sd-1-5:${weight}> ${PROMPT}"
done

echo "Comparación terminada. Revisar los PNG y JSON más recientes en outputs/."

