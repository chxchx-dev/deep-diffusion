# Presets de generación

La interfaz web permite guardar configuraciones reutilizables desde el panel
`Presets`. Los presets se guardan en el `localStorage` del navegador y no se
envían a ningún servicio externo.

## Qué se guarda

- Prompt y negative prompt.
- Resolución, seed y cantidad de imágenes.
- Sampler, scheduler, pasos y CFG.
- LoRAs y multiplicadores.
- VAE tiling, conditioning y opciones de caché.
- Formato y compresión de salida.

Las imágenes auxiliares de img2img, inpainting y control se mantienen solo en
la sesión actual y no se incluyen en los presets.

## Uso recomendado

1. Configurar los controles de generación.
2. Escribir un nombre, por ejemplo `anime watercolor`.
3. Pulsar `Save current`.
4. Seleccionar el preset para cargarlo en otra generación.

Los presets son locales al navegador y al origen de la interfaz. Para
respaldarlos, conservar el perfil del navegador o exportarlos manualmente en
una futura versión de la interfaz.
