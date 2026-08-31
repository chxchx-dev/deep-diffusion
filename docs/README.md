# Documentación de deep-diffusion

Este es el índice de la documentación activa. Separa el uso del producto, su
desarrollo y la evidencia de operación. `AGENTS.md` es la entrada para las
herramientas de desarrollo que necesitan contexto del repositorio.

Diagnóstico documental y de estructura: `pnpm run doctor`.

## Estado y criterios de trabajo

- [Desarrollo y documentación](DEVELOPMENT.md): cómo trabajar en el proyecto y
  mantener sus fuentes documentales.
- [Automatización del desarrollo](ai/AGENT_USAGE.md): Codex, Claude Code y
  OpenCode.
- [Estado operativo](ai/PROJECT_STATE.md): resumen corto y actualizado.
- [Mapa documental](ai/DOCUMENTATION_MAP.md): fuente responsable por tema.
- [Reglas de trabajo](RULES.md): invariantes de código, datos y operación.
- [Decisiones](DECISIONS.md): decisiones técnicas y de producto.
- [Riesgos](RISKS.md): riesgos abiertos y mitigaciones.
- [Backlog](BACKLOG.md): trabajo pendiente priorizado.
- [Historial](archive/HISTORY.md): hitos cerrados y evidencia histórica.

## Uso del producto y operación

- [Arquitectura](ARCHITECTURE.md)
- [Preparación del entorno](SETUP.md)
- [Interfaz web](WEB-UI.md)
- [Modelos](MODELS.md)
- [LoRAs](LORAS.md)
- [Presets](PRESETS.md)
- [Rendimiento](PERFORMANCE.md)
- [Mantenimiento](MAINTENANCE.md)
- [Seguridad y privacidad](SECURITY.md)

## Referencias del desarrollo

- [Workflows](../workflows/README.md): rutas para features, bugs, arquitectura,
  seguridad, releases, documentación y baselines.

Los workflows enlazan a los documentos que necesitan y no duplican la
documentación del producto.

## Alcance

El código y las pruebas son la evidencia efectiva. Los archivos en
`docs/archive/` explican el recorrido, pero no gobiernan cambios nuevos.
Los datos pesados y locales permanecen fuera del control de versiones según
`.gitignore`.
