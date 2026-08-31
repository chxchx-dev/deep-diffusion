# Uso de agentes

## Contrato compartido

El proyecto se puede trabajar con Codex, Claude Code u OpenCode sin duplicar
reglas. Todos deben usar:

- `AGENTS.md` como entrada y límite común.
- `docs/ai/PROJECT_STATE.md` para el estado actual.
- `docs/README.md` y `docs/ai/DOCUMENTATION_MAP.md` para encontrar la fuente
  canónica.
- Un workflow de `workflows/` según el tipo de cambio.
- Un rol de `docs/ai/agents/` según la responsabilidad.

La precedencia es código y pruebas, documentación activa, reglas de entrada y,
por último, backlog o archivo histórico. Si una fuente contradice al código,
se corrige la fuente obsoleta y se registra una decisión cuando el impacto lo
requiera.

## Codex

Codex lee `AGENTS.md` desde la raíz del repositorio. Para una tarea:

1. Identifica feature, bugfix, arquitectura, seguridad, release o docs.
2. Lee el workflow y el rol aplicables.
3. Inspecciona solo el módulo necesario mediante progressive disclosure.
4. Implementa, prueba y sincroniza la documentación.
5. Ejecuta:

   ```bash
   pnpm run doctor
   ./tools/verify-project.sh
   git diff --check
   ```

Solicitud recomendada:

> Actúa como `implementer`. Lee `AGENTS.md`, `docs/ai/PROJECT_STATE.md` y
> `workflows/FEATURE.md`. Implementa [alcance], prueba casos negativos y
> entrega archivos cambiados, validaciones y pendientes.

## Claude Code

Claude Code comienza en `CLAUDE.md`. Ese archivo importa `AGENTS.md` y no
contiene reglas paralelas. El uso recomendado es el mismo que en Codex:

- elegir el rol antes de editar;
- consultar `docs/` como fuente canónica;
- mantener cambios pequeños y reversibles;
- ejecutar doctor, verificador y pruebas antes de entregar.

Solicitud recomendada:

> Usa `CLAUDE.md` y `AGENTS.md`. Actúa como `reviewer` para revisar este diff.
> No edites; reporta hallazgos por severidad, evidencia y pruebas faltantes.

## OpenCode

OpenCode usa `AGENTS.md` como contrato del repositorio. No necesita una copia
de la arquitectura ni un archivo de reglas alternativo. Debe consultar los
roles y workflows versionados en `docs/ai/` y `workflows/`, igual que los otros
agentes.

Solicitud recomendada:

> Lee `AGENTS.md`, `docs/ai/PROJECT_STATE.md` y `workflows/BUGFIX.md`. Actúa
> como `debugger`: reproduce [fallo], demuestra la causa, añade una regresión
> y reporta el riesgo residual.

## Selección rápida de rol

| Necesidad | Rol |
| --- | --- |
| Delimitar una decisión que cruza módulos | `architect` |
| Implementar una tarea aprobada | `implementer` |
| Reproducir y corregir un fallo | `debugger` |
| Revisar un cambio sin editar | `reviewer` |
| Auditar exposición, rutas, secretos o contenido sensible | `security-reviewer` |

## Formato de entrega

Cada agente debe reportar alcance, archivos cambiados, validaciones ejecutadas,
evidencia relevante, limitaciones y pendientes. El modelo utilizado se decide
fuera del repositorio; no se fija un modelo dentro de los roles.
