#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE="${1:-}"

if [[ -z "${ARCHIVE}" || ! -f "${ARCHIVE}" ]]; then
  echo "Uso: $0 /ruta/al/respaldo.tar.gz --confirm" >&2
  exit 2
fi
if [[ "${2:-}" != "--confirm" ]]; then
  echo "La restauración sobrescribirá configuración, documentación, workflows, scripts y registros." >&2
  echo "Repite con --confirm para continuar." >&2
  exit 2
fi

tar -tzf "${ARCHIVE}" >/dev/null
tar -xzf "${ARCHIVE}" -C "${ROOT_DIR}"
echo "Respaldo restaurado desde: ${ARCHIVE}"
