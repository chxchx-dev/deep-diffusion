# Estado operativo de deep-diffusion

**Última evidencia funcional disponible:** 2026-08-31
**Estado:** baseline local en evolución; validación Vulkan pendiente en el host gráfico.

## Qué existe

- Motor local `stable-diffusion.cpp` en `vendor/`, con CLI y servidor.
- CLI para `txt2img`, `img2img` e inpainting, con PNG, JSON y registro CSV.
- Frontend React + Vite en `web/`, servido como frontend compilado del servidor.
- Supervisor local para selección secuencial de modelos desde `models/`.
- Presets, recetas e historial guardados en el navegador.
- Baseline SD 1.5: 512×512, batch 1, 20 pasos, CFG 7, seed 42.

## Evidencia disponible

- Smoke test CPU 64×64/1 paso completado; el log está en
  `logs/benchmark-cpu-smoke-final-20260808-004234.txt`.
- El servidor CPU arrancó en `http://127.0.0.1:1234`.
- El modelo y el LoRA activos tienen hash y ficha en `docs/MODELS.md` y
  `docs/LORAS.md`.
- El frontend React + Vite pasó type-check y build de producción; se generó
  `web/dist/index.html` autocontenido el 2026-08-31.
- El bundle de producción y su header embebible se sirvieron/generaron
  correctamente en loopback durante la validación del 2026-08-31.

## Límites conocidos

- `ggml_vulkan` reportó `No devices found` en el entorno de la evidencia; no
  usar esa sesión para afirmar rendimiento Vulkan.
- Los archivos pesados de `models/`, `loras/`, `outputs/` y `logs/` son locales
  y están excluidos del control de versiones.
- El backlog P0 define la siguiente puerta de validación.

## Para iniciar una tarea

Lee `AGENTS.md`, el workflow aplicable y el documento de la zona afectada. Al
terminar, ejecuta el doctor y actualiza este estado solo si cambió la realidad
operativa, no para registrar cada paso de implementación.
