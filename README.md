# deep-diffusion

> Herramienta local y privada para generar y editar imágenes con Stable Diffusion.cpp.

`deep-diffusion` combina un motor ligero compilado localmente, aceleración Vulkan y una
interfaz web de loopback con flujos reproducibles desde CLI. Está pensado para
equipos con memoria y GPU integrada limitadas.

Repositorio: `git@github.com:chxchx-dev/deep-diffusion.git`

## Propósito

Construir una estación local, reproducible y auditable para experimentar con
generación y edición de imágenes sin enviar prompts, imágenes, modelos ni
resultados a servicios externos. El objetivo es conservar un núcleo pequeño:
un motor local, un CLI confiable, una interfaz web de loopback y evidencia
suficiente para repetir cada resultado.

## Autor

Proyecto iniciado y mantenido por **chxchxn-dev** como una herramienta personal
de generación local, reproducible y orientada a hardware accesible.

## Características

- `txt2img`, `img2img` e inpainting desde CLI.
- Interfaz web local en `127.0.0.1`.
- Soporte para LoRAs compatibles con SD 1.5.
- Detección de múltiples modelos locales y selección por configuración.
- Presets configurables para prompts y parámetros de generación.
- PNG y metadatos JSON por ejecución.
- Benchmarks y configuración orientados a AMD Vega 7.

## Qué se lleva y qué se quiere lograr

### Ya disponible

- Motor `stable-diffusion.cpp` aislado en `vendor/`, con CLI y servidor local.
- Flujos `txt2img`, `img2img` e inpainting con PNG, JSON y registro CSV.
- Frontend React + Vite, presets, recetas, historial local y cambio secuencial
  de modelos.
- Baseline definido: SD 1.5, 512×512, batch 1, 20 pasos, CFG 7 y seed 42.
- Gobernanza común para agentes en `AGENTS.md`, workflows, roles, decisiones,
  riesgos, backlog y diagnóstico automático.

### Objetivo inmediato

Cerrar la validación Vulkan en el host gráfico de la Vega 7, comprobar los
controles web contra el CLI y mantener una configuración estable antes de
incorporar modelos, resoluciones o capacidades nuevas.

### Fuera de alcance por ahora

No se busca convertirlo en una plataforma cloud, exponerlo a la red, entrenar
modelos, añadir vídeo ni acumular funciones sin benchmark, licencia, memoria y
rollback documentados.

## Arquitectura

```text
CLI / interfaz web
        │
        ▼
 stable-diffusion.cpp
     ┌──┴───┐
     │      │
  Vulkan  CPU/CLIP
     │      │
     └──┬───┘
        ▼
 PNG + JSON reproducible
```

El baseline utiliza SD 1.5 a 512×512, batch 1, 20 pasos y CFG 7. La difusión y
el VAE se ejecutan en Vulkan; CLIP permanece en CPU para ajustarse al hardware
objetivo.

## Requisitos

- Linux con Vulkan funcional.
- CPU x86-64 y, para el perfil recomendado, GPU AMD integrada.
- CMake, Ninja, compilador C++17 y Python 3.
- Node.js y pnpm solo para recompilar la interfaz embebida.

El motor `stable-diffusion.cpp` se prepara localmente en
`vendor/stable-diffusion.cpp`; sus fuentes y binarios no forman parte del
repositorio público por tamaño y licencia independiente.

## Uso rápido

Clona el repositorio nuevo:

```bash
git clone git@github.com:chxchx-dev/deep-diffusion.git
cd deep-diffusion
```

Después de compilar el motor y colocar un modelo compatible en `models/`:

```bash
./tools/generate.sh "a cozy cabin in a misty pine forest, cinematic lighting"
```

Para ver todos los modelos instalados:

```bash
./tools/list-models.sh
```

Para iniciar la interfaz web local:

```bash
RADV_PERFTEST=nogttspill ./tools/run-web.sh
```

También puedes usar los comandos generales desde la raíz:

```bash
pnpm run install
pnpm run doctor
pnpm run build
pnpm run start
```

`pnpm run start` ejecuta únicamente el frontend React compilado junto con el
backend y el supervisor local. No inicia una segunda instancia de Vite.

No se usa Docker como requisito del proyecto: el acceso nativo a Vulkan, los
modelos locales y el rendimiento de la Vega 7 son más directos fuera de un
contenedor. Docker puede evaluarse más adelante para distribución CPU o CI.

Abre `http://127.0.0.1:1234`. La interfaz permite seleccionar modelos locales,
configurar prompt, negative prompt, resolución, seed, sampler, LoRA, peso,
pasos y CFG, además de guardar
presets en el navegador.

## Documentación

- [Índice documental y gobierno](docs/README.md)
- [Uso de agentes](docs/ai/AGENT_USAGE.md)
- [Estado operativo](docs/ai/PROJECT_STATE.md)
- [Reglas de trabajo](docs/RULES.md)
- [Backlog y riesgos](docs/BACKLOG.md) · [Riesgos](docs/RISKS.md)
- [Decisiones](docs/DECISIONS.md)
- [Instalación y configuración](docs/SETUP.md)
- [Arquitectura](docs/ARCHITECTURE.md)
- [Uso de la interfaz web](docs/WEB-UI.md)
- [Frontend web](web/README.md)
- [Presets](docs/PRESETS.md)
- [Rendimiento](docs/PERFORMANCE.md)
- [Modelos compatibles](docs/MODELS.md)
- [Flujos CLI](workflows/txt2img-baseline.md)

## Gobernanza y uso de agentes

Todos los agentes comparten la misma fuente de verdad. El flujo normal es:

1. Leer `AGENTS.md` y `docs/ai/PROJECT_STATE.md`.
2. Clasificar la tarea y leer el workflow correspondiente.
3. Elegir un rol de `docs/ai/agents/`.
4. Implementar el slice mínimo y actualizar solo la fuente documental afectada.
5. Ejecutar `pnpm run doctor`, `./tools/verify-project.sh`, las pruebas
   relevantes y `git diff --check`.

| Herramienta | Entrada | Forma de trabajo |
| --- | --- | --- |
| Codex | `AGENTS.md` | Usa el rol y workflow aplicables; entrega evidencia de comandos y pendientes. |
| Claude Code | `CLAUDE.md` → `AGENTS.md` | Usa el mismo estado, reglas y workflows; `CLAUDE.md` solo funciona como adaptador. |
| OpenCode | `AGENTS.md` | Sigue el mismo contrato del repositorio y no crea una fuente paralela de reglas. |

La guía detallada con ejemplos de solicitudes, selección de roles y formato de
entrega está en [docs/ai/AGENT_USAGE.md](docs/ai/AGENT_USAGE.md). Cambiar de
agente no debe cambiar la arquitectura, el estado ni los criterios de calidad.

## Privacidad y alcance

El proyecto está diseñado para ejecutarse localmente: imágenes, prompts y
modelos no se envían a servicios externos. No incluye funciones de desnudo
automático ni sexualización de personas reales; cualquier uso de personajes
adultos debe ser ficticio y claramente adulto.

## Licencia

Este proyecto se distribuye bajo la [licencia MIT](LICENSE). El motor incluido
conserva su propia licencia; los modelos y LoRAs tienen licencias independientes
y no forman parte de este repositorio.
