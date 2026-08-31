# Workflows y baselines

Esta carpeta contiene los recorridos reproducibles para cambiar y validar el
proyecto. Los workflows indican qué evidencia entregar; la documentación de
producto sigue siendo la fuente canónica de comportamiento y operación.

## Cambios de desarrollo

| Tipo | Workflow |
| --- | --- |
| Feature | [FEATURE.md](FEATURE.md) |
| Bugfix | [BUGFIX.md](BUGFIX.md) |
| Cambio de arquitectura | [ARCHITECTURE_CHANGE.md](ARCHITECTURE_CHANGE.md) |
| Revisión de seguridad | [SECURITY_REVIEW.md](SECURITY_REVIEW.md) |
| Release | [RELEASE.md](RELEASE.md) |
| Documentación | [DOCS_SYNC.md](DOCS_SYNC.md) |

## Baselines de uso

- [txt2img](txt2img-baseline.md)
- [img2img](img2img-baseline.md)
- [Inpainting](inpainting-baseline.md)

Cada baseline debe poder ejecutarse con recursos locales disponibles y dejar
configuración, metadatos y limitaciones explícitas. No se deben afirmar
métricas de un host o dispositivo que no haya sido validado.
