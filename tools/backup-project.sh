#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-${ROOT_DIR}/backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/deep-diffusion-${STAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"

tar -czf "${BACKUP_FILE}" -C "${ROOT_DIR}" \
  README.md .gitignore \
  configs docs workflows experiments tools vendor/README.md

echo "Respaldo creado: ${BACKUP_FILE}"
echo "Contenido: configuración, documentación, workflows, scripts y registros."
echo "No incluye modelos, LoRAs, imágenes, builds ni dependencias vendorizadas."
