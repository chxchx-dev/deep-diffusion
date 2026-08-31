# deep-diffusion — instrucciones para agentes

Este archivo es la entrada común para Codex, Claude Code, OpenCode y agentes
compatibles. Mantén las reglas aquí breves; la información del producto vive
en `docs/`.

## Orden de lectura

1. `docs/ai/PROJECT_STATE.md`
2. `docs/README.md` y el workflow que corresponda a la tarea
3. La regla o documento del módulo afectado
4. `docs/DECISIONS.md`, `docs/BACKLOG.md` y `docs/RISKS.md` solo si la tarea los afecta

## Precedencia

1. Código, contratos y pruebas que se puedan ejecutar.
2. Arquitectura y reglas vigentes en `docs/`.
3. Este archivo y sus adaptadores.
4. Backlog, propuestas y archivo histórico.

Si dos fuentes contradicen el comportamiento comprobado, corrige la fuente
obsoleta y registra una decisión cuando el impacto sea relevante.

## Límites del proyecto

- El servicio y las imágenes permanecen locales; no agregar exposición de red
  ni servicios externos sin una decisión explícita.
- No versionar modelos, LoRAs, outputs, logs, builds, secretos ni preferencias
  personales.
- No sobrescribir imágenes de entrada ni resultados anteriores.
- Mantener el CLI como referencia reproducible y la interfaz web como capa de
  operación sobre el mismo motor.
- Los prompts deben usar material propio, ficticio o autorizado; no añadir
  funciones para desnudar digitalmente o sexualizar personas reales.

## Cómo trabajar

- Clasifica el cambio como feature, bugfix, arquitectura, seguridad, release o
  documentación y lee su workflow en `workflows/`.
- Haz el slice mínimo, prueba casos positivos y negativos proporcionales al
  riesgo y actualiza la documentación afectada.
- No inventes métricas: si un host o dispositivo no está disponible, registra
  la limitación en `docs/ai/PROJECT_STATE.md` o `docs/RISKS.md`.
- Ejecuta `bash docs/ai/scripts/doctor.sh`, `./tools/verify-project.sh`, `git diff --check` y las pruebas
  relevantes antes de entregar.

## Uso según la herramienta

- **Codex:** toma `AGENTS.md` como entrada, lee el workflow y el rol en
  `docs/ai/agents/` y ejecuta `pnpm run doctor` antes de entregar.
- **Claude Code:** comienza en `CLAUDE.md`, que importa estas mismas reglas;
  no crees una segunda versión de la arquitectura o del estado.
- **OpenCode:** usa `AGENTS.md` como contrato del repositorio y sigue el mismo
  workflow, rol, validaciones y formato de entrega que los otros agentes.

La guía detallada y ejemplos de solicitud están en
`docs/ai/AGENT_USAGE.md`. Cambiar de herramienta no cambia las reglas ni la
fuente de verdad.

## Entrega mínima

Reporta alcance, archivos cambiados, validaciones ejecutadas, evidencia
relevante y cualquier pendiente o comando que no haya sido posible ejecutar.
