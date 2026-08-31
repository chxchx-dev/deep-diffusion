#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_DIR="${ROOT_DIR}/models"

if [[ ! -d "${MODEL_DIR}" ]]; then
  echo "No existe el directorio de modelos: ${MODEL_DIR}" >&2
  exit 1
fi

found=0
while IFS= read -r -d '' model; do
  found=1
  relative="${model#"${ROOT_DIR}/"}"
  size="$(du -h "${model}" | awk '{print $1}')"
  printf '%s\t%s\n' "${relative}" "${size}"
done < <(find "${MODEL_DIR}" -maxdepth 1 -type f \( \
  -iname '*.safetensors' -o -iname '*.ckpt' -o -iname '*.gguf' -o -iname '*.bin' \
\) -print0 | sort -z)

if [[ "${found}" -eq 0 ]]; then
  echo "No se encontraron modelos compatibles en ${MODEL_DIR}." >&2
  exit 1
fi
