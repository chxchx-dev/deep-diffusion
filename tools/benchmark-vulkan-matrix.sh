#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_VALUE="${BACKEND_OVERRIDE:-clip=cpu,vae=vulkan0,diffusion=vulkan0}"
WIDTH_VALUE="${WIDTH_OVERRIDE:-512}"
HEIGHT_VALUE="${HEIGHT_OVERRIDE:-512}"

if [[ "${SKIP_DEVICE_CHECK:-0}" != "1" ]]; then
  ENGINE="${ROOT_DIR}/vendor/stable-diffusion.cpp/build/bin/sd-cli"
  if [[ ! -x "${ENGINE}" ]]; then
    echo "Falta sd-cli: ${ENGINE}" >&2
    exit 1
  fi
  if ! "${ENGINE}" --list-devices | grep -q "Vulkan0"; then
    echo "No se detectó Vulkan0. Ejecuta este script en el host gráfico de la Vega 7." >&2
    exit 1
  fi
fi

for steps in 15 20 30; do
  echo "=== Vulkan ${WIDTH_VALUE}x${HEIGHT_VALUE}, ${steps} pasos ==="
  BACKEND_OVERRIDE="${BACKEND_VALUE}" \
  WIDTH_OVERRIDE="${WIDTH_VALUE}" \
  HEIGHT_OVERRIDE="${HEIGHT_VALUE}" \
  STEPS_OVERRIDE="${steps}" \
  BENCHMARK_TAG="vulkan-${WIDTH_VALUE}x${HEIGHT_VALUE}-${steps}" \
    "${ROOT_DIR}/tools/benchmark.sh"
done

echo "Matriz Vulkan completada. Revisa los logs benchmark-vulkan-* en logs/."
