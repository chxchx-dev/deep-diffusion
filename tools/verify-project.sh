#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL="${ROOT_DIR}/models/v1-5-pruned-emaonly.safetensors"
EXPECTED_SHA256="6ce0161689b3853acaa03779ec93eafe75a02f4ced659bee03f50797806fa2fa"
ERRORS=0

check() {
  if "$@"; then
    echo "OK: $*"
  else
    echo "FAIL: $*" >&2
    ERRORS=$((ERRORS + 1))
  fi
}

check test -f "${MODEL}"
check test -x "${ROOT_DIR}/tools/generate.sh"
check test -x "${ROOT_DIR}/tools/edit-image.sh"
check test -x "${ROOT_DIR}/tools/benchmark.sh"
check test -x "${ROOT_DIR}/tools/run-web.sh"
check test -x "${ROOT_DIR}/tools/backup-project.sh"
check test -x "${ROOT_DIR}/tools/restore-project.sh"
check test -f "${ROOT_DIR}/configs/default.env"
check test -f "${ROOT_DIR}/experiments/registry.csv"

if [[ -f "${MODEL}" ]]; then
  ACTUAL_SHA256="$(sha256sum "${MODEL}" | awk '{print $1}')"
  if [[ "${ACTUAL_SHA256}" == "${EXPECTED_SHA256}" ]]; then
    echo "OK: modelo SHA-256 ${ACTUAL_SHA256}"
  else
    echo "FAIL: SHA-256 esperado ${EXPECTED_SHA256}, actual ${ACTUAL_SHA256}" >&2
    ERRORS=$((ERRORS + 1))
  fi
fi

if python3 - "${ROOT_DIR}" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
metadata = sorted((root / "outputs").glob("*.json"))
if not metadata:
    raise SystemExit("no hay metadatos JSON")
required = {"model", "model_sha256", "prompt", "seed", "backend", "sampling_method"}
for path in metadata:
    data = json.loads(path.read_text(encoding="utf-8"))
    missing = required - data.keys()
    if missing:
        raise SystemExit(f"{path}: faltan campos {sorted(missing)}")
    if "loras" not in data:
        print(f"Aviso: {path} usa metadatos legacy sin campo loras")
print(f"{len(metadata)} JSON de salida válidos")
PY
then
  echo "OK: metadatos de outputs"
else
  echo "FAIL: metadatos de outputs" >&2
  ERRORS=$((ERRORS + 1))
fi

bash -n "${ROOT_DIR}/tools/generate.sh" "${ROOT_DIR}/tools/edit-image.sh" \
  "${ROOT_DIR}/tools/benchmark.sh" "${ROOT_DIR}/tools/run-web.sh" \
  "${ROOT_DIR}/tools/backup-project.sh" "${ROOT_DIR}/tools/restore-project.sh"
if [[ "$?" -eq 0 ]]; then
  echo "OK: sintaxis de scripts"
else
  echo "FAIL: sintaxis de scripts" >&2
  ERRORS=$((ERRORS + 1))
fi

if [[ "$ERRORS" -ne 0 ]]; then
  echo "Verificación fallida: ${ERRORS} problema(s)." >&2
  exit 1
fi
echo "Verificación completa."
