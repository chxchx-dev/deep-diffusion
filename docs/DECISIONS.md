# Decisiones del proyecto

| Fecha      | Decisión                                          | Motivo                                                                         |
| ---------- | ------------------------------------------------- | ------------------------------------------------------------------------------ |
| 2026-08-07 | Empezar con SD 1.5                                | Mejor equilibrio para Vega 7 y 16 GB de RAM                                    |
| 2026-08-07 | Priorizar `stable-diffusion.cpp` + Vulkan         | Menor complejidad y consumo inicial                                            |
| 2026-08-07 | Mantener el proyecto local                        | Privacidad de imágenes y prompts                                               |
| 2026-08-07 | Permitir `BACKEND_OVERRIDE=cpu` para validaciones | El entorno actual no expone Vulkan; Vulkan sigue siendo el backend por defecto |
| 2026-08-07 | Registrar hash, commit, sampler y duración        | Hacer cada generación auditable y reproducible                                 |
| 2026-08-07 | Seleccionar peso LoRA `0.6` como predeterminado   | Mejor equilibrio visual observado entre efecto acuarela y artefactos a 512×512 |
| 2026-08-07 | Mantener estilos y parámetros como configuración  | Permitir presets anime, acuarela u otros sin modificar scripts ni código       |
| 2026-08-31 | Adoptar `AGENTS.md` + `docs/` como gobierno canónico | Mantener trazabilidad común entre agentes y separar estado, reglas, decisiones, riesgos e historial |
| 2026-08-31 | Renombrar el proyecto a `deep-diffusion` | Alinear repositorio, paquetes, interfaz, metadatos y rutas propias con el nuevo nombre público |
| 2026-08-31 | Enfocar la documentación en uso y desarrollo del software | Retirar el playbook genérico de gobierno y mantener solo las guías específicas del proyecto |
| 2026-08-31 | Mantener React + Vite como frontend vigente | Unificar el desarrollo web en React, conservar el contrato nativo de `stable-diffusion.cpp` y cerrar la transición desde Vue con un plan verificable |
| 2026-08-31 | No mantener archivos `.env.example` | Evitar configuraciones de ejemplo desactualizadas; los defaults y presets versionables son la referencia y los overrides son locales |
