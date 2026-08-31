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

La interfaz web incluye un selector de recetas (`Load example recipe`) para
cargar directamente prompts y ajustes de generación. No es una galería de
imágenes: cada receta es un punto de partida editable y no guarda resultados.

Incluye ejemplos de personaje anime, retrato anime, paisaje fantástico, logo
de mascota e icono de producto. Después de cargar una receta se puede ajustar
cualquier campo y pulsar `Save current` si se quiere conservar una variante
personal.

La interfaz también mantiene un historial local de ejecuciones. Este guarda la
configuración y el estado para volver a cargarla o exportarla, pero excluye las
imágenes auxiliares y no almacena los PNG generados.

El archivo `configs/presets/examples.json` contiene presets importables para:

- Personaje anime con acuarela.
- Retrato anime.
- Paisaje fantástico.
- Mascota para logo.
- Icono de producto.

En la interfaz, usa `Import JSON` y selecciona ese archivo. Para logos se
recomienda generar primero el símbolo sin texto y añadir la tipografía después;
SD 1.5 no garantiza lettering limpio.
