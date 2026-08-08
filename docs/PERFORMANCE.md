# Fase 4 — Rendimiento y estabilidad

## Objetivo

Encontrar la configuración útil para Ryzen 5 5500U, Radeon Vega 7 y 16 GiB de
RAM sin sacrificar estabilidad. El backend Vulkan es el objetivo; CPU sirve como
fallback y control de funcionamiento.

## Ejecución

El benchmark usa el mismo modelo, seed y prompt en cada prueba:

```bash
./tools/benchmark.sh
```

Los overrides no modifican `configs/default.env`:

```bash
BACKEND_OVERRIDE=cpu WIDTH_OVERRIDE=64 HEIGHT_OVERRIDE=64 \
STEPS_OVERRIDE=1 BENCHMARK_TAG=cpu-smoke ./tools/benchmark.sh
```

Cada ejecución guarda un log en `logs/` y una imagen de control en `outputs/`.
`/usr/bin/time -v` registra tiempo transcurrido y memoria residente máxima.

## Matriz para el host con Vulkan

Ejecutar las filas en orden y detenerse si aparece un error de memoria, bloqueo
del driver o temperatura anormal:

| Backend | Resolución | Pasos | Propósito |
|---|---:|---:|---|
| `clip=cpu,vae=vulkan0,diffusion=vulkan0` | 512×512 | 15 | mínimo útil |
| `clip=cpu,vae=vulkan0,diffusion=vulkan0` | 512×512 | 20 | baseline |
| `clip=cpu,vae=vulkan0,diffusion=vulkan0` | 512×512 | 30 | calidad/tiempo |
| `clip=cpu,vae=vulkan0,diffusion=vulkan0` | 576×576 | 20 | límite intermedio |
| `clip=cpu,vae=vulkan0,diffusion=vulkan0` | 768×768 | 20 | solo si 576 es estable |
| `cpu` | 512×512 | 20 | fallback, solo si es necesario |

Ejemplo parametrizado:

```bash
BACKEND_OVERRIDE='clip=cpu,vae=vulkan0,diffusion=vulkan0' \
WIDTH_OVERRIDE=512 HEIGHT_OVERRIDE=512 STEPS_OVERRIDE=20 \
BENCHMARK_TAG=vulkan-512x512-20 ./tools/benchmark.sh
```

## Criterios de aceptación

- La imagen se genera y el proceso termina con código 0.
- No hay errores Vulkan ni corrupción de salida.
- La memoria máxima queda dentro de los límites del equipo.
- Repetir seed, prompt y parámetros produce resultados comparables.
- La configuración recomendada se elige por estabilidad primero y tiempo
  después.

## Estado de este entorno

Aquí `ggml_vulkan` no detecta dispositivos y los sockets están restringidos;
por eso la matriz Vulkan debe ejecutarse en el host gráfico de la Vega 7. La
prueba CPU completa de 512×512/20 pasos es demasiado lenta para usarla como
smoke test; se permite la prueba 64×64/1 paso para validar el script.
