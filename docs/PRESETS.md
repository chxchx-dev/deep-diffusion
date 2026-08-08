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
respaldarlos, se pueden guardar también como archivos `.env` versionables en
`configs/presets/`. El preset público de ejemplo se ejecuta así:

```bash
CONFIG_FILE_OVERRIDE=configs/presets/anime-watercolor.env \
  ./tools/generate.sh "original anime character, adult woman, silver hair, blue eyes"
```

Los presets portables no deben contener prompts personales, rutas absolutas,
modelos, LoRAs ni imágenes.

## Ejemplos incluidos

El archivo `configs/presets/examples.json` contiene presets importables para:

- Personaje anime con acuarela.
- Retrato anime.
- Paisaje fantástico.
- Mascota para logo.
- Icono de producto.

En la interfaz, usa `Import JSON` y selecciona ese archivo. Para logos se
recomienda generar primero el símbolo sin texto y añadir la tipografía después;
SD 1.5 no garantiza lettering limpio.
