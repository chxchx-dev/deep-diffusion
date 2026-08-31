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

En la sesión de cierre del 8 de agosto de 2026, `sd-cli --list-devices`
reportó únicamente el dispositivo CPU y `ggml_vulkan: No devices found`. Por
eso no se inventan métricas Vulkan: la matriz debe ejecutarse desde el host
gráfico donde esté expuesta la Vega 7.

Prueba ejecutada correctamente en este entorno:

| Backend | Resolución | Pasos | Resultado | Tiempo | Memoria máxima |
|---|---:|---:|---|---:|---:|
| `cpu` | 64×64 | 1 | PNG generado, código 0 | 5.87 s | 3.23 GiB |

Log: `logs/benchmark-cpu-smoke-final-20260808-004234.txt`.

La interfaz también arrancó correctamente con CPU y confirmó:

```text
listening on: http://127.0.0.1:1234
```

Esto valida el fallback y el alcance por loopback, pero no sustituye el
benchmark Vulkan. Para cerrar Fase 4 en el host de la Vega 7, ejecutar como
mínimo:

```bash
./tools/benchmark-vulkan-matrix.sh
```

El script comprueba primero que exista `Vulkan0`, detiene la matriz ante un
fallo y conserva un log independiente por cantidad de pasos. Para repetir la
prueba con otra resolución, por ejemplo 576×576:

```bash
WIDTH_OVERRIDE=576 HEIGHT_OVERRIDE=576 ./tools/benchmark-vulkan-matrix.sh
```

Conservar los tres logs y registrar en esta tabla el tiempo, memoria máxima,
temperatura observada y si apareció `DeviceLost`. Solo probar 576×576 y
768×768 si las tres filas de 512×512 terminan correctamente.
