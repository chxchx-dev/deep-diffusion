# Historial resumido

Este archivo conserva contexto cerrado sin convertirlo en instrucciones activas.

## 2026-08-07 — baseline inicial

- Se eligió `stable-diffusion.cpp` con SD 1.5, Vulkan para difusión/VAE y CPU
  para CLIP, orientado a Ryzen 5 5500U, Vega 7 y 16 GiB de RAM.
- Se habilitaron `txt2img`, `img2img`, inpainting, metadatos JSON y registro
  CSV.
- Se registraron modelo, LoRA, hashes y primeras ejecuciones en `logs/` y
  `experiments/registry.csv`.

## 2026-08-08 — frontend y validación local

- El frontend pasó a React + Vite y se añadió un supervisor local para cambio
  secuencial de modelo.
- El smoke test CPU y el arranque web en `127.0.0.1:1234` quedaron validados.
- La sesión disponible no expuso dispositivos Vulkan; el benchmark objetivo
  quedó pendiente del host gráfico.

La evidencia detallada permanece en los logs locales ignorados y en las fichas
activas de arquitectura, modelos, rendimiento y mantenimiento. El antiguo
informe técnico y el plan maestro se retiraron como fuentes activas porque
duplicaban ese contenido; los pendientes vigentes están en `docs/BACKLOG.md`.
