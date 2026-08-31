# Backlog activo

Solo se mantienen aquí pendientes que aún requieren trabajo. Las tareas
cerradas o los planes históricos viven en `docs/archive/HISTORY.md`.

## P0 — bloquea la validación del baseline

- [ ] Ejecutar la matriz Vulkan de 512×512 en el host gráfico con Vega 7 y
  registrar tiempo, memoria, temperatura y `DeviceLost`.
- [ ] Validar desde el navegador los controles web y su equivalencia con el
  CLI usando el backend disponible.

## P1 — mejora operativa

- [ ] Registrar el commit exacto de `stable-diffusion.cpp` junto con cada
  benchmark futuro.
- [ ] Cerrar la comparación visual del LoRA watercolor con evidencia del mismo
  host y mantener la decisión provisional revisable.

## P2 — solo con justificación

- [ ] Evaluar 576×576 y 768×768 únicamente si 512×512 es estable.
- [ ] Evaluar nuevos modelos, upscale o ControlNet solo con benchmark,
  licencia, memoria y rollback documentados.
