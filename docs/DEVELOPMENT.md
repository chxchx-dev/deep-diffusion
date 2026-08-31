# Desarrollo y documentación

Este documento explica cómo demostrar el desarrollo y el uso reproducible de
`deep-diffusion`. La documentación activa está organizada por responsabilidad;
el código, las pruebas y los registros ejecutables son la evidencia principal.

## Dónde buscar

- `README.md`: propósito, instalación rápida y recorrido de uso.
- `docs/README.md`: índice de documentación activa.
- `docs/ARCHITECTURE.md`: componentes y límites del sistema.
- `docs/SETUP.md` y `docs/MAINTENANCE.md`: preparación, respaldo y verificación.
- `docs/WEB-UI.md`: operación de la interfaz web.
- `docs/MODELS.md`, `docs/LORAS.md` y `docs/PRESETS.md`: recursos y
  configuraciones reproducibles.
- `docs/DECISIONS.md`, `docs/RISKS.md` y `docs/BACKLOG.md`: decisiones vigentes,
  riesgos abiertos y trabajo pendiente.
- `workflows/`: procedimientos para cada tipo de cambio y baselines de uso.
- `docs/archive/`: historial cerrado; no contiene instrucciones activas.

El mapa completo y la fuente canónica de cada tema están en
[`docs/ai/DOCUMENTATION_MAP.md`](ai/DOCUMENTATION_MAP.md).

## Flujo de desarrollo

1. Leer `AGENTS.md`, `docs/ai/PROJECT_STATE.md` y el workflow que corresponda.
2. Identificar el módulo y su documento canónico antes de editar.
3. Hacer el cambio mínimo manteniendo el CLI y la interfaz web sobre el mismo
   motor local.
4. Probar el recorrido positivo y los errores relevantes para el cambio.
5. Actualizar arquitectura, decisión, riesgo, backlog o instrucciones solo si
   cambió la realidad del proyecto.
6. Entregar los archivos cambiados, comandos ejecutados, evidencia y pendientes.

## Evidencia de uso

Para una validación local, conservar la configuración y los metadatos que
permitan repetir el resultado:

```bash
pnpm run doctor
./tools/verify-project.sh
./tools/generate.sh "a cozy cabin in a misty pine forest, cinematic lighting"
git diff --check
```

Las generaciones deben conservar PNG, JSON y registro CSV sin sobrescribir
entradas ni resultados anteriores. Los benchmarks y sus limitaciones se
documentan en `docs/PERFORMANCE.md` y `docs/ai/PROJECT_STATE.md`.

## Documentación de cambios

La documentación debe responder qué cambió, cómo se comprobó y qué queda
pendiente. Un cambio de comportamiento requiere actualizar el documento de
uso correspondiente; una decisión transversal va en `docs/DECISIONS.md`; una
limitación no resuelta va en `docs/RISKS.md` o `docs/BACKLOG.md`.

La guía de herramientas automatizadas está separada en
[`docs/ai/AGENT_USAGE.md`](ai/AGENT_USAGE.md); no sustituye la documentación de
producto ni crea una segunda arquitectura.
