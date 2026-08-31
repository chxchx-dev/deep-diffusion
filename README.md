# deep-diffusion

> Herramienta local y privada para generar y editar imágenes con `stable-diffusion.cpp`.

`deep-diffusion` combina un motor local, una interfaz web React + Vite y scripts
CLI reproducibles. Todo el flujo está diseñado para ejecutarse en loopback, sin
enviar prompts, imágenes, modelos ni resultados a servicios externos.

Repositorio: `https://github.com/chxchx-dev/deep-diffusion`

## Estado actual

- Frontend migrado de Vue a React + TypeScript + Vite.
- Bundle web autocontenido mediante `vite-plugin-singlefile`.
- CLI para `txt2img`, `img2img` e inpainting.
- API web nativa de `stable-diffusion.cpp` con polling y cancelación de jobs.
- Presets, recetas, historial local y exportación de configuraciones.
- Supervisor local para descubrir modelos y cambiar de modelo secuencialmente.
- PNG, metadatos JSON y registro CSV para ejecuciones reproducibles.
- Baseline: SD 1.5, 512×512, batch 1, 20 pasos, CFG 7 y seed 42.

La migración y sus criterios de cierre están documentados en
[`docs/REACT-VITE-MIGRATION.md`](docs/REACT-VITE-MIGRATION.md).

## Arquitectura

```text
CLI / React + Vite
        │
        ▼
Supervisor local en loopback
        │
        ▼
stable-diffusion.cpp (sd-server / sd-cli)
        │
        ├── Vulkan para difusión y VAE
        └── CPU para CLIP y fallback
        │
        ▼
PNG + JSON + registro CSV
```

El CLI continúa siendo la referencia reproducible. La interfaz web es una capa
de operación sobre el mismo motor y contrato local; no existe un backend cloud.

## Requisitos y plataforma

Para el flujo completo se usa Linux con:

- CPU x86-64.
- AMD Vega 7 para el perfil documentado.
- Vulkan funcional, CMake, Ninja y compilador C++17.
- Python 3.
- Node.js `>= 20` y pnpm `>= 10` para el frontend.

En macOS se puede instalar dependencias y validar el frontend React/Vite, pero
el backend completo y los benchmarks Vulkan de este proyecto están documentados
para el host Linux con Vega 7. No se deben extrapolar sus métricas a la Mac.

El motor se prepara localmente en `vendor/stable-diffusion.cpp`; sus fuentes,
binarios, modelos y LoRAs pesados no forman parte del repositorio. Sigue
[`vendor/README.md`](vendor/README.md) para compilar `sd-cli` y `sd-server`.

## Instalación y primer build

Clona el repositorio y entra en su directorio:

```bash
git clone https://github.com/chxchx-dev/deep-diffusion.git
cd deep-diffusion
```

Instala las dependencias web:

```bash
pnpm run install
```

Prepara el motor siguiendo [`vendor/README.md`](vendor/README.md), coloca un
modelo compatible directamente en `models/` y revisa
[`docs/MODELS.md`](docs/MODELS.md).

Para compilar solo el frontend React/Vite:

```bash
pnpm --dir web type-check
pnpm --dir web build
pnpm --dir web build:header
```

Esto genera `web/dist/index.html` y el header embebible
`web/dist/gen_index_html.h`. El directorio `web/dist/` es generado y no se
versiona.

## Uso desde CLI

Generación de texto a imagen:

```bash
./tools/generate.sh "a cozy cabin in a misty pine forest, cinematic lighting"
```

Edición de imagen y rellenado por máscara:

```bash
./tools/edit-image.sh img2img path/to/input.png "cinematic forest lighting"
./tools/edit-image.sh inpaint path/to/input.png path/to/mask.png "a painted window"
```

Los resultados se guardan en `outputs/` sin sobrescribir ejecuciones anteriores.
Cada ejecución registra parámetros, modelo, hash, backend y duración en JSON y
en `experiments/registry.csv`.

Para listar o seleccionar modelos:

```bash
./tools/list-models.sh
MODEL_OVERRIDE=models/otro-modelo.safetensors \
  ./tools/generate.sh "a detailed fantasy landscape"
```

Los LoRAs compatibles con SD 1.5 se activan desde el prompt:

```bash
./tools/generate.sh "<lora:mi-lora:0.6> portrait of a fictional character"
```

Consulta [`docs/LORAS.md`](docs/LORAS.md) antes de incorporar un archivo nuevo.

## Uso de la interfaz web

Después de compilar el frontend y preparar el modelo, inicia el servicio local:

```bash
pnpm run start
```

También puedes ejecutar directamente:

```bash
./tools/run-web.sh
```

Abre `http://127.0.0.1:1234`. La interfaz permite configurar prompt, negative
prompt, resolución, seed, sampler, pasos, CFG, LoRAs y VAE tiling. También
incluye:

- recetas editables para anime, retratos, paisajes, logos e iconos;
- presets guardados en `localStorage`;
- historial local de ejecuciones, sin PNG ni imágenes auxiliares;
- selección secuencial de modelos desde `models/`;
- polling, cancelación y previsualización de jobs.

Para desarrollar la interfaz con Vite:

```bash
pnpm --dir web dev
```

El backend local debe estar disponible en otra terminal mediante
`./tools/run-web.sh`. Vite usa por defecto `http://127.0.0.1:1234` como destino
de proxy; se puede cambiar con `VITE_API_PROXY_TARGET` en un archivo local
`web/.env`.

## Configuración local

Los valores reproducibles están en [`configs/default.env`](configs/default.env)
y los presets portables en `configs/presets/*.env`.

No se crean ni se versionan archivos `.env.example`, `.env.local.example` ni
variantes similares. Los overrides personales se mantienen en archivos `.env`
ignorados, como `web/.env`, y nunca deben incluir secretos en el repositorio.

## Validación

Checks del frontend:

```bash
pnpm --dir web type-check
pnpm --dir web build
pnpm --dir web build:header
```

Checks del repositorio y documentación:

```bash
pnpm run doctor
git diff --check
```

El check integrado ejecuta frontend y verificación operativa:

```bash
pnpm run build
```

`pnpm run build` requiere además el modelo local, al menos un JSON en
`outputs/` y `experiments/registry.csv`; para una copia recién clonada usa
primero los checks del frontend. La verificación completa puede ejecutarse con:

```bash
./tools/verify-project.sh
```

El benchmark CPU/Vulkan y las pruebas de equivalencia entre web y CLI se
documentan en [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md) y
[`docs/WEB-UI.md`](docs/WEB-UI.md). La validación Vulkan debe realizarse en el
host gráfico correspondiente.

## Desarrollo y documentación

La documentación está separada por responsabilidad:

- [`docs/README.md`](docs/README.md): índice activo.
- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md): flujo de desarrollo y evidencia.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): diseño y límites.
- [`docs/REACT-VITE-MIGRATION.md`](docs/REACT-VITE-MIGRATION.md): transición del
  frontend.
- [`docs/SETUP.md`](docs/SETUP.md), [`docs/WEB-UI.md`](docs/WEB-UI.md) y
  [`docs/MAINTENANCE.md`](docs/MAINTENANCE.md): instalación y operación.
- [`docs/MODELS.md`](docs/MODELS.md), [`docs/LORAS.md`](docs/LORAS.md) y
  [`docs/PRESETS.md`](docs/PRESETS.md): recursos reproducibles.
- [`docs/DECISIONS.md`](docs/DECISIONS.md), [`docs/RISKS.md`](docs/RISKS.md) y
  [`docs/BACKLOG.md`](docs/BACKLOG.md): decisiones, riesgos y pendientes.
- [`workflows/README.md`](workflows/README.md): workflows de desarrollo y
  baselines de uso.

Para cambios asistidos por herramientas, `AGENTS.md` enruta al workflow y a la
fuente documental correspondiente. La guía específica está en
[`docs/ai/AGENT_USAGE.md`](docs/ai/AGENT_USAGE.md).

## Privacidad, seguridad y alcance

- El servicio escucha únicamente en `127.0.0.1`.
- Las rutas de modelos se limitan a archivos directamente dentro de `models/`.
- Prompts, imágenes, modelos y LoRAs permanecen en el equipo.
- No se versionan modelos, LoRAs, outputs, logs, builds, secretos ni datos
  personales.
- Los prompts deben usar material propio, ficticio o autorizado.
- El proyecto no incluye funciones para desnudar digitalmente ni sexualizar
  personas reales.
- No se busca convertirlo en una plataforma cloud, entrenar modelos ni añadir
  vídeo sin una decisión y validación específicas.

## Distribución y licencias

El código propio de la raíz no incluye una licencia de distribución declarada.
La interfaz web conserva el aviso de licencia de su código upstream en
[`web/LICENSE`](web/LICENSE). El motor, los modelos y los LoRAs tienen licencias
independientes; no forman parte del código propio de este repositorio.
