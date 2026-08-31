# Documentación de deep-diffusion

Este es el índice de la documentación activa. `AGENTS.md` es la entrada para
agentes; este archivo indica dónde vive cada tipo de conocimiento.

Diagnóstico documental y de estructura: `pnpm run doctor`.

## Estado y gobierno

- [Uso de agentes](ai/AGENT_USAGE.md): Codex, Claude Code y OpenCode.
- [Estado operativo](ai/PROJECT_STATE.md): resumen corto y actualizado.
- [Mapa documental](ai/DOCUMENTATION_MAP.md): fuente responsable por tema.
- [Reglas de trabajo](RULES.md): invariantes de código, datos y operación.
- [Decisiones](DECISIONS.md): decisiones técnicas y de producto.
- [Riesgos](RISKS.md): riesgos abiertos y mitigaciones.
- [Backlog](BACKLOG.md): trabajo pendiente priorizado.
- [Historial](archive/HISTORY.md): hitos cerrados y evidencia histórica.

## Producto y operación

- [Arquitectura](ARCHITECTURE.md)
- [Preparación del entorno](SETUP.md)
- [Interfaz web](WEB-UI.md)
- [Modelos](MODELS.md)
- [LoRAs](LORAS.md)
- [Presets](PRESETS.md)
- [Rendimiento](PERFORMANCE.md)
- [Mantenimiento](MAINTENANCE.md)
- [Seguridad y privacidad](SECURITY.md)

## Workflows

- [Feature](../workflows/FEATURE.md)
- [Bugfix](../workflows/BUGFIX.md)
- [Cambio de arquitectura](../workflows/ARCHITECTURE_CHANGE.md)
- [Revisión de seguridad](../workflows/SECURITY_REVIEW.md)
- [Release](../workflows/RELEASE.md)
- [Sincronización documental](../workflows/DOCS_SYNC.md)

## Alcance

El código y las pruebas son la evidencia efectiva. Los archivos en
`docs/archive/` explican el recorrido, pero no gobiernan cambios nuevos.
Los datos pesados y locales permanecen fuera del control de versiones según
`.gitignore`.
