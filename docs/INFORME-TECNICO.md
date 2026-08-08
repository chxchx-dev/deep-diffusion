# Informe técnico de `deep-n`

**Fecha de corte:** 2026-08-07  
**Estado:** baseline local operativo, con validación Vulkan pendiente en el host gráfico  
**Propósito:** documentar qué se ha construido, qué componentes se usan, qué modelos están instalados y qué partes siguen pendientes de validación.

## Resumen ejecutivo

`deep-n` es una herramienta local y privada para generación y edición de imágenes mediante Stable Diffusion. El motor actualmente utilizado es **`stable-diffusion.cpp`**, compilado desde el código vendorizado en `vendor/stable-diffusion.cpp`.

No se está usando Easy Diffusion, Stable Diffusion WebUI Forge, ComfyUI ni `sd.cpp` como un producto separado. En este proyecto, `sd.cpp` es la forma abreviada de referirse a **`stable-diffusion.cpp`**, que proporciona los ejecutables `sd-cli` y `sd-server`.

La configuración objetivo es un equipo con Fedora 44, AMD Ryzen 5 5500U, Radeon Vega 7 y 16 GiB de RAM. El baseline es SD 1.5 a 512×512, batch 1, 20 pasos, CFG 7 y seed 42.

## Stack tecnológico

| Capa | Tecnología utilizada | Función |
|---|---|---|
| Motor de inferencia | `stable-diffusion.cpp` | Carga del modelo y ejecución de txt2img, img2img e inpainting |
| CLI | `sd-cli` | Generaciones reproducibles y automatización desde Bash |
| Servidor web | `sd-server` | Interfaz HTTP local para operar el motor |
| Frontend | Interfaz web embebida de `stable-diffusion.cpp` | Prompt, parámetros, presets y carga de imágenes |
| GPU | Vulkan / `ggml_vulkan` | Difusión y VAE en el perfil recomendado |
| CPU | CPU del Ryzen 5 5500U | CLIP/text encoder y fallback completo |
| Automatización | Bash + Python estándar | Lanzamiento, validación y generación de metadatos |
| Build | CMake + Ninja + compilador C/C++ | Compilación local del motor |
| Formato de modelos | SafeTensors y LoRA SafeTensors | Pesos del modelo base y adaptadores |
| Registro | PNG + JSON + CSV | Trazabilidad y reproducción de experimentos |

### Herramientas no utilizadas

No forman parte de la arquitectura actual:

- Easy Diffusion.
- Forge / Stable Diffusion WebUI Forge.
- ComfyUI.
- AUTOMATIC1111.
- Servicios cloud o APIs externas de generación.
- Entrenamiento local de modelos o LoRAs.

La elección de `stable-diffusion.cpp` responde a la necesidad de reducir consumo, dependencias y complejidad operacional en una Vega 7. La interfaz web se mantiene como una capa de operación sobre el mismo motor; el CLI continúa siendo la referencia para pruebas.

## Hardware y sistema objetivo

Según `logs/environment.txt`:

| Elemento | Valor |
|---|---|
| Sistema operativo | Fedora 44, KDE Plasma |
| CPU | AMD Ryzen 5 5500U with Radeon Graphics |
| GPU | AMD Radeon Vega 7 / Lucienne |
| RAM | 16 GiB instalados; aproximadamente 14 GiB reportados por el sistema |
| RAM disponible durante la revisión | 7.1 GiB |
| API gráfica | Vulkan |
| Espacio libre registrado | 341 GB en `/home` |

El equipo es suficiente para un baseline SD 1.5 de baja resolución, pero no es un perfil apropiado para asumir de entrada modelos grandes, resoluciones altas, batch múltiple o vídeo.

## Modelo base

### Stable Diffusion 1.5

- **Archivo:** `models/v1-5-pruned-emaonly.safetensors`
- **Formato:** SafeTensors
- **Tamaño:** 4,265,146,304 bytes
- **SHA-256:** `6ce0161689b3853acaa03779ec93eafe75a02f4ced659bee03f50797806fa2fa`
- **Fuente:** [stable-diffusion-v1-5 en Hugging Face](https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5)
- **Licencia declarada:** CreativeML OpenRAIL-M
- **Uso actual:** txt2img, img2img e inpainting locales

El hash se valida desde `tools/verify-project.sh` para evitar ejecutar accidentalmente un archivo sustituido o incompleto.

## LoRA instalado

Está instalado un único adaptador compatible con SD 1.5:

- **Archivo:** `loras/fladdict-watercolor-sd-1-5.safetensors`
- **Fuente:** [fladdict/watercolor en Hugging Face](https://huggingface.co/fladdict/watercolor)
- **SHA-256:** `7a4575799077438d47435e841d5ad4560e0f83d0ade5ce7e15a6125c7b443d99`
- **Pesos probados:** `0.4`, `0.6` y `0.8`
- **Peso recomendado provisionalmente:** `0.6`

La activación se expresa en el prompt con la sintaxis:

```text
<lora:fladdict-watercolor-sd-1-5:0.6>
```

El soporte se habilita mediante `--lora-model-dir loras/` y `LORA_APPLY_MODE=immediately`. Las pruebas mínimas confirmaron la carga del LoRA en CPU. También existen generaciones 512×512 con backend Vulkan y pesos `0.4`, `0.6` y `0.8`; la elección visual definitiva debe conservarse como una decisión revisable.

## Backend y distribución de carga

La configuración base en `configs/default.env` es:

```text
BACKEND="clip=cpu,vae=vulkan0,diffusion=vulkan0"
VAE_TILING=1
```

Esto significa:

1. **CLIP/text encoder:** CPU.
2. **Difusión:** dispositivo Vulkan `vulkan0`, normalmente la Vega 7.
3. **VAE:** Vulkan `vulkan0`.
4. **VAE tiling:** activado para reducir la presión de memoria durante la decodificación.

El backend `cpu` se conserva como fallback de validación. El backend Vulkan no debe darse por disponible solo porque el binario fue compilado con `SD_VULKAN=ON`: el dispositivo debe ser visible en la sesión gráfica donde se ejecuta la prueba.

## Parámetros baseline

| Parámetro | Valor |
|---|---:|
| Modelo | SD 1.5 `v1-5-pruned-emaonly.safetensors` |
| Resolución | 512×512 |
| Batch | 1 |
| Pasos | 20 |
| CFG scale | 7 |
| Seed | 42 |
| Sampler | `euler_a` |
| Negative prompt | Vacío por defecto |
| LoRA | Opcional; peso provisional `0.6` |
| VAE tiling | Activado |
| Salida | PNG + JSON |

Las variables `*_OVERRIDE` permiten experimentar sin modificar la configuración persistente, por ejemplo `BACKEND_OVERRIDE=cpu` o `WIDTH_OVERRIDE=64`.

## Flujos implementados

### txt2img

```bash
./tools/generate.sh "a cozy cabin in a misty pine forest, cinematic lighting"
```

`tools/generate.sh` valida el ejecutable y el modelo, genera un PNG con timestamp, calcula el SHA-256 del modelo, registra la versión del motor y crea un JSON y una fila en `experiments/registry.csv`.

### img2img e inpainting

```bash
./tools/edit-image.sh img2img outputs/entrada.png "watercolor study of the same scene"
./tools/edit-image.sh inpaint outputs/entrada.png masks/validation-mask.png "a small ceramic vase"
```

El script conserva la imagen original, valida las rutas de entrada y máscara y registra `strength`, modo, imagen de entrada y máscara en los metadatos.

### Interfaz web

El servidor se inicia con:

```bash
./tools/run-web.sh
```

Escucha explícitamente en `127.0.0.1:1234`. No se configura `0.0.0.0` ni exposición a la red. El frontend embebido permite configurar prompt, negative prompt, resolución, seed, sampler, pasos, CFG, LoRAs y VAE tiling; los presets se almacenan en `localStorage` del navegador.

## Trazabilidad y reproducibilidad

Cada ejecución debe conservar:

- PNG generado.
- JSON con prompt, modelo, hash, seed, resolución, pasos, CFG, sampler, backend, LoRAs, duración y plataforma.
- Registro resumido en `experiments/registry.csv`.
- Workflow o configuración que permita reconstruir la ejecución.

El verificador `tools/verify-project.sh` comprueba rutas, permisos, hash del modelo, sintaxis Bash y campos mínimos de los JSON.

## Resultados registrados

### Smoke test CPU

- Resolución: 64×64.
- Pasos: 1.
- Backend: `cpu`.
- Resultado: completado correctamente.
- Tiempo de generación reportado por el motor: 2.57 s.
- Tiempo total de proceso reportado por `/usr/bin/time`: aproximadamente 13 s.
- Memoria residente máxima: aproximadamente 3.24 GiB.

Este resultado valida el pipeline, pero no representa el rendimiento útil del baseline 512×512.

### Generaciones Vulkan registradas

Se registraron generaciones 512×512 con 20 pasos, seed 42 y LoRA watercolor:

| Peso LoRA | Duración registrada |
|---:|---:|
| 0.4 | 99 s |
| 0.6 | 103 s |
| 0.8 | 117 s |

También existe una generación 512×512 de un personaje ficticio con LoRA `0.4`, de 97 s. El benchmark Vulkan de referencia registró 93.80 s de generación y una memoria residente máxima de aproximadamente 1.59 GiB, según `logs/benchmark-default-20260807-202714.txt`.

## Estado de validación

### Confirmado

- Código fuente de `stable-diffusion.cpp` presente en `vendor/`.
- `sd-cli` y `sd-server` compilados y ejecutables.
- Build configurado con `SD_VULKAN=ON`.
- Modelo SD 1.5 presente y hash validado.
- LoRA presente y hash validado.
- txt2img, img2img e inpainting probados con el fallback CPU en smoke tests.
- Generaciones 512×512 registradas con backend mixto y metadatos.
- Servidor web iniciado en `127.0.0.1:1234` con CPU.
- Scripts de generación, edición, benchmark, servidor y verificación disponibles.

### Pendiente o condicionado al host gráfico

- Repetir benchmark Vulkan final desde una sesión gráfica con la Vega 7 visible.
- Validar navegación HTTP desde el navegador del host.
- Probar todos los controles web y su equivalencia con el CLI.
- Confirmar de forma comparativa el peso LoRA definitivo.
- Medir temperatura, estabilidad y límite práctico de 576×576 y 768×768.

## Incidencias y observaciones de mantenimiento

Los logs históricos contienen rutas antiguas bajo `tools/stable-diffusion.cpp`, mientras que la estructura actual utiliza `vendor/stable-diffusion.cpp`. Los scripts vigentes apuntan a `vendor/`; conviene normalizar los logs y documentación histórica antes de usarlos como evidencia de una nueva compilación.

También hay diferencia entre algunas opciones descritas en el log de build y la caché CMake actual: la caché disponible muestra `Release`, `SD_VULKAN=ON`, `SD_SERVER_BUILD_FRONTEND=OFF`, `SD_WEBP=ON` y `SD_WEBM=ON`. Para una auditoría de build futura, conservar el comando CMake exacto, el commit del motor y el contenido de `CMakeCache.txt` en el mismo registro.

## Decisiones de arquitectura

1. Mantener `stable-diffusion.cpp` como motor principal por consumo y simplicidad.
2. Priorizar SD 1.5 antes de incorporar modelos mayores.
3. Usar Vulkan para difusión/VAE y CPU para CLIP.
4. Mantener el servicio en loopback.
5. Usar el CLI como referencia reproducible y la web como interfaz operativa.
6. No incorporar funciones para desnudar digitalmente ni sexualizar personas reales.
7. No entrenar modelos ni LoRAs en este equipo.

## Comandos operativos de referencia

```bash
# Verificación estructural y de integridad
./tools/verify-project.sh

# Generación baseline
./tools/generate.sh "a red apple on a wooden table, studio lighting, detailed"

# Benchmark Vulkan objetivo
BENCHMARK_TAG=vulkan-512x512-20 ./tools/benchmark.sh

# Smoke test CPU
BACKEND_OVERRIDE=cpu WIDTH_OVERRIDE=64 HEIGHT_OVERRIDE=64 \
STEPS_OVERRIDE=1 BENCHMARK_TAG=cpu-smoke ./tools/benchmark.sh

# Arranque de la interfaz local
./tools/run-web.sh
```

## Próximos pasos recomendados

1. Ejecutar la matriz de rendimiento en el host gráfico real.
2. Confirmar la interfaz web y los controles de generación.
3. Normalizar las rutas de los logs antiguos.
4. Registrar el commit exacto del motor junto con cada benchmark.
5. Cerrar la comparación LoRA con criterio visual y datos del mismo host.
6. Evaluar cualquier modelo o ampliación futura solo después de benchmark, licencia, memoria y procedimiento de rollback.

## Referencias internas

- [README principal](../README.md)
- [Arquitectura](ARCHITECTURE.md)
- [Configuración e instalación](SETUP.md)
- [Modelos](MODELS.md)
- [LoRAs](LORAS.md)
- [Rendimiento](PERFORMANCE.md)
- [Interfaz web](WEB-UI.md)
- [Plan del proyecto](PLAN.md)
- [Decisiones](DECISIONS.md)
- [Mantenimiento](MAINTENANCE.md)
