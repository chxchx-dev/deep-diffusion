# Plan general de gobierno para agentes de IA

Documento reutilizable para iniciar o reorganizar proyectos medianos y grandes
que serán trabajados con Codex, Claude Code, OpenCode u otros agentes compatibles.

Este plan describe una arquitectura de conocimiento y trabajo. No contiene
reglas de un producto concreto: cada proyecto debe sustituir los ejemplos por
sus propias decisiones, comandos, módulos y riesgos.

## 1. Objetivo

Crear un sistema donde varios agentes puedan trabajar sobre el mismo proyecto
sin que cada herramienta invente sus propias reglas, arquitectura o estado.

El sistema debe responder rápidamente a cinco preguntas:

1. ¿Cuál es la fuente de verdad?
2. ¿Qué debe leer el agente para esta tarea?
3. ¿Qué rol y permisos tiene?
4. ¿Cómo se verifica que el cambio está terminado?
5. ¿Dónde queda documentada una decisión o un pendiente?

## 2. Principio central

Mantener una sola fuente de conocimiento y varios adaptadores de herramienta.

```text
                    ┌──────────────────────┐
                    │ Código + pruebas     │ evidencia efectiva
                    └──────────┬───────────┘
                               │
┌───────────────┐    ┌─────────▼──────────┐    ┌────────────────┐
│ Codex         │    │ docs/ y docs/ai/   │    │ Claude Code    │
│ AGENTS.md     │───►│ fuente canónica    │◄───│ CLAUDE.md      │
└───────────────┘    └─────────┬──────────┘    └────────────────┘
                               │
                    ┌─────────▼──────────┐
                    │ OpenCode           │
                    │ AGENTS.md          │
                    └────────────────────┘
```

Las reglas del producto no se copian dentro de prompts, agentes o skills. Los
adaptadores solo enrutan hacia los documentos canónicos.

## 3. Estructura recomendada

### Base mínima

```text
proyecto/
├── AGENTS.md                 # entrada común para agentes
├── CLAUDE.md                 # adaptador: importa AGENTS.md
├── README.md                 # instalación y uso humano
├── docs/
│   ├── README.md             # índice y estado global
│   ├── ARCHITECTURE.md       # arquitectura vigente
│   ├── RULES.md              # reglas de trabajo
│   ├── DECISIONS.md          # ADRs
│   ├── RISKS.md              # deuda y riesgos
│   ├── BACKLOG.md            # pendientes priorizados
│   └── ai/
│       ├── PROJECT_STATE.md
│       ├── ARCHITECTURE.md
│       ├── workflows/
│       └── agents/
├── .claude/
│   ├── agents/
│   └── skills/
└── .opencode/
    └── agents/
```

### Base para proyectos grandes

```text
docs/
├── README.md                 índice único
├── ARCHITECTURE.md           diseño técnico vigente
├── RULES.md                  reglas transversales
├── RULES-<DOMAIN>.md         reglas específicas de dominio
├── DECISIONS.md              ADRs vigentes e históricos
├── CONTRACTS.md              contratos públicos
├── DATA-MODEL.md             invariantes persistentes
├── OPERATIONS.md             despliegue, observabilidad y recuperación
├── SECURITY.md               amenazas y controles
├── BACKLOG.md                trabajo futuro
├── ai/
│   ├── PROJECT_STATE.md      resumen operativo corto
│   ├── ARCHITECTURE.md       arquitectura de IA
│   ├── DOCUMENTATION_MAP.md  dónde vive cada tipo de información
│   ├── workflows/            cómo ejecutar clases de tarea
│   └── agents/               responsabilidades de roles
└── archive/
    └── HISTORY.md            decisiones o trabajos ya cerrados
```

No es obligatorio crear todos los archivos desde el primer día. Se agregan
cuando existe contenido real que justifica una responsabilidad independiente.

## 4. Responsabilidad de cada capa

| Capa | Contiene | No debe contener |
| --- | --- | --- |
| `AGENTS.md` | entrada, orden de lectura, límites y definición de terminado | arquitectura completa o manuales largos |
| `CLAUDE.md` | import de `AGENTS.md` y excepciones mínimas de Claude | una segunda copia de las reglas |
| `docs/` | conocimiento vigente del producto y sistema | prompts específicos de una herramienta |
| `docs/ai/` | estado, workflows, roles y gobierno de contexto | decisiones de negocio duplicadas |
| `agents/` | responsabilidad, alcance y permisos de un rol | modelo, secretos o reglas del dominio |
| `skills/` | cómo aplicar una capacidad repetible | estado del proyecto completo |
| `archive/` | historial y referencias no vigentes | instrucciones activas |
| código/tests | comportamiento real y evidencia | depender de una descripción obsoleta |

## 5. Fuente de verdad y precedencia

Definir la precedencia explícitamente:

1. comportamiento comprobado por código, contratos, migraciones y pruebas;
2. reglas y arquitectura vigentes en `docs/`;
3. `AGENTS.md` y adaptadores, que solo enrutan y fijan límites;
4. backlog, propuestas y documentos históricos.

Una contradicción no se resuelve eligiendo silenciosamente un documento. Se
identifica la fuente correcta, se corrige la fuente obsoleta y se deja un ADR si
la decisión es importante.

## 6. Flujo estándar de trabajo

```text
solicitud
   ↓
clasificar: feature / bug / arquitectura / seguridad / release / docs
   ↓
leer PROJECT_STATE + un workflow
   ↓
leer la regla y el módulo afectados
   ↓
elegir rol o skill
   ↓
implementar el slice mínimo
   ↓
probar comportamiento y casos negativos
   ↓
sincronizar contrato, decisión, riesgo o backlog
   ↓
ejecutar doctor y entregar evidencia
```

La regla de contexto es progressive disclosure: un agente no debe cargar todos
los documentos del repositorio para una tarea local.

## 7. Roles recomendados

Comenzar con cinco roles y añadir otros solo cuando exista una necesidad real:

- `architect`: delimita alcance, dependencias, alternativas y ADRs.
- `implementer`: implementa el slice y sus pruebas.
- `debugger`: reproduce, demuestra causa y crea regresiones.
- `reviewer`: revisa calidad, seguridad, alcance y pruebas sin editar.
- `security-reviewer`: audita abuso, permisos, secretos y exposición de datos.

Cada rol debe definir:

- objetivo;
- documentos que debe leer;
- acciones permitidas y prohibidas;
- formato de salida;
- condición de terminado.

No se asignan modelos dentro del repositorio. El modelo es una decisión del
orquestador, del usuario o de la configuración local.

## 8. Workflows mínimos

Crear un workflow por tipo de cambio, no por persona ni por modelo:

| Workflow | Resultado esperado |
| --- | --- |
| `FEATURE.md` | slice completo, pruebas y documentación sincronizada |
| `BUGFIX.md` | reproducción, causa demostrada y regresión |
| `ARCHITECTURE_CHANGE.md` | decisión registrada y migración reversible |
| `SECURITY_REVIEW.md` | hallazgos, impacto, mitigación y cierre |
| `RELEASE.md` | evidencia de build, operación, smoke tests y rollback |
| `DOCS_SYNC.md` | índices correctos y ninguna fuente duplicada |

## 9. Skills

Una skill debe existir cuando una capacidad se repite y necesita decisiones
especializadas. Su estructura mínima es:

```text
.claude/skills/<skill-name>/
└── SKILL.md
```

La skill debe incluir:

1. cuándo se activa;
2. qué fuentes canónicas debe leer;
3. invariantes específicas;
4. flujo de aplicación;
5. validación y límites.

Para compartir Claude y OpenCode, mantener una sola skill en `.claude/skills/`
si la versión instalada de OpenCode tiene compatibilidad con esa ubicación. Si
una herramienta no la descubre automáticamente, `AGENTS.md` debe indicar la
ruta explícita. Codex puede aplicarla leyendo su `SKILL.md` cuando la tarea la
requiera.

Ejemplos de skills útiles: sistema de diseño, arquitectura .NET, contratos API,
migraciones de base de datos, accesibilidad, release o revisión de seguridad.

## 10. Reglas para proyectos grandes

- Cada módulo importante puede tener un `AGENTS.md` o regla específica cercana a
  su código.
- Las reglas locales refinan la raíz; no pueden contradecirla sin ADR.
- Los contratos públicos tienen una versión y una política de compatibilidad.
- Seguridad, tenancy, dinero, migraciones y release siempre incluyen pruebas
  negativas o evidencia operativa.
- Los agentes de revisión no editan por defecto.
- Los cambios paralelos que toquen los mismos archivos usan worktrees o una cola
  de integración.
- Los secretos y preferencias personales viven fuera del repositorio.
- Los documentos activos deben ser cortos; los procedimientos largos usan
  referencias específicas y se cargan solo cuando aplican.

## 11. Archivo e historial

Archivar no significa duplicar todo lo viejo. Antes de mover algo:

1. identifica qué decisiones siguen vigentes;
2. trasládalas al documento canónico actual;
3. conserva en `archive/` solo la evidencia que ayude a entender el recorrido;
4. elimina planes, checklists y borradores que ya no aporten información;
5. actualiza el índice y comprueba enlaces.

Un repositorio limpio puede tener un único `HISTORY.md` por iniciativa cerrada,
en vez de conservar diez documentos de seguimiento con casillas ya resueltas.

## 12. Validación común

Cada proyecto debe tener un comando de diagnóstico, por ejemplo:

```bash
bash docs/ai/scripts/doctor.sh
git diff --check
```

El doctor debe comprobar como mínimo:

- archivos de entrada presentes;
- documentos canónicos presentes;
- contrato y comandos básicos identificables;
- skills y agentes con rutas válidas;
- ausencia de referencias a archivos retirados;
- ausencia de secretos, builds o estado local;
- formato básico del diff.

La compilación no sustituye la revisión documental. Una tarea puede compilar y
seguir estando mal gobernada si dejó una regla vieja o un contrato desactualizado.

## 13. Plan de adopción por fases

### Fase 1 — inventario

Localizar READMEs, reglas, ADRs, planes, checklists, configuraciones de agentes,
skills, contratos y documentación duplicada.

### Fase 2 — fuente canónica

Elegir un documento responsable para cada tema y crear el mapa documental.
Marcar como históricos los documentos que ya no gobiernan el presente.

### Fase 3 — entrada común

Crear `AGENTS.md`, el adaptador `CLAUDE.md`, reglas por módulo y una definición
de terminado. Mantenerlos deliberadamente breves.

### Fase 4 — workflows y roles

Crear workflows para las clases de cambio que realmente ocurren y los cinco
roles base. No crear un agente por cada archivo o equipo.

### Fase 5 — skills especializadas

Convertir prácticas repetidas — diseño, API, seguridad, datos, releases— en
skills pequeñas, con fuentes y validación explícitas.

### Fase 6 — enforcement

Agregar doctor, comprobación de enlaces, validaciones de contrato y CI para que
la gobernanza no dependa de que una persona recuerde las reglas.

### Fase 7 — mejora continua

Después de cada cambio relevante, revisar si apareció una contradicción, una
regla repetida, una skill demasiado grande o un documento que ya debe archivarse.

## 14. Checklist de arranque

- [ ] `AGENTS.md` existe y es el punto de entrada.
- [ ] `CLAUDE.md` importa las reglas comunes.
- [ ] Existe un README con comandos reales.
- [ ] Existe un índice documental.
- [ ] Existe un estado operativo corto.
- [ ] Existen reglas de arquitectura, seguridad y calidad acordes al proyecto.
- [ ] Existe un workflow de feature, bugfix y release.
- [ ] Existen roles de implementación y revisión.
- [ ] Las skills están versionadas y no duplican reglas.
- [ ] Existe un doctor ejecutable.
- [ ] El histórico está separado de las instrucciones activas.
- [ ] No hay secretos, builds ni configuraciones personales versionadas.

## 15. Checklist de entrega de una tarea

- [ ] El cambio tiene alcance y criterio de aceptación.
- [ ] Se leyó el workflow correcto.
- [ ] Se respetaron reglas del módulo y contratos.
- [ ] Se añadieron pruebas proporcionales al riesgo.
- [ ] Se probaron permisos, tenant o casos negativos cuando aplicaba.
- [ ] Se actualizó ADR, riesgo, backlog o documentación cuando correspondía.
- [ ] El agente reportó lo que no pudo ejecutar.
- [ ] El doctor y las validaciones relevantes pasan.

## 16. Resultado esperado

El objetivo no es tener más archivos, sino reducir ambigüedad. Un proyecto bien
gobernado permite que una persona cambie de Codex a Claude Code u OpenCode y
encuentre el mismo estado, las mismas reglas, los mismos roles y la misma forma
de verificar el trabajo.
