# deep-n

> Herramienta local y privada para generar y editar imágenes con Stable Diffusion.cpp.

`deep-n` combina un motor ligero compilado localmente, aceleración Vulkan y una
interfaz web de loopback con flujos reproducibles desde CLI. Está pensado para
equipos con memoria y GPU integrada limitadas.

## Autor

Proyecto iniciado y mantenido por **chxchxn-dev** como una herramienta personal
de generación local, reproducible y orientada a hardware accesible.

## Características

- `txt2img`, `img2img` e inpainting desde CLI.
- Interfaz web local en `127.0.0.1`.
- Soporte para LoRAs compatibles con SD 1.5.
- Presets configurables para prompts y parámetros de generación.
- PNG y metadatos JSON por ejecución.
- Benchmarks y configuración orientados a AMD Vega 7.

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

Después de compilar el motor y colocar un modelo compatible en `models/`:

```bash
./tools/generate.sh "a cozy cabin in a misty pine forest, cinematic lighting"
```

Para iniciar la interfaz web local:

```bash
RADV_PERFTEST=nogttspill ./tools/run-web.sh
```

Abre `http://127.0.0.1:1234`. La interfaz permite configurar prompt, negative
prompt, resolución, seed, sampler, LoRA, peso, pasos y CFG, además de guardar
presets en el navegador.

## Documentación

- [Instalación y configuración](docs/SETUP.md)
- [Arquitectura](docs/ARCHITECTURE.md)
- [Uso de la interfaz web](docs/WEB-UI.md)
- [Presets](docs/PRESETS.md)
- [Rendimiento](docs/PERFORMANCE.md)
- [Modelos compatibles](docs/MODELS.md)
- [Flujos CLI](workflows/txt2img-baseline.md)

La planificación interna y el registro privado de decisiones se mantienen fuera
de la documentación pública del repositorio.

## Privacidad y alcance

El proyecto está diseñado para ejecutarse localmente: imágenes, prompts y
modelos no se envían a servicios externos. No incluye funciones de desnudo
automático ni sexualización de personas reales; cualquier uso de personajes
adultos debe ser ficticio y claramente adulto.

## Licencia

Este proyecto se distribuye bajo la [licencia MIT](LICENSE). El motor incluido
conserva su propia licencia; los modelos y LoRAs tienen licencias independientes
y no forman parte de este repositorio.
