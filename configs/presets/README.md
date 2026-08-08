# Presets versionables

Los archivos `.env` de esta carpeta son presets portables para el CLI. Cada
preset debe cargar primero `configs/default.env` y sobrescribir únicamente los
valores que cambian.

Uso:

```bash
CONFIG_FILE_OVERRIDE=configs/presets/anime-watercolor.env \
  ./tools/generate.sh "original anime character, adult woman, silver hair, blue eyes"
```

No guardes aquí prompts personales, rutas absolutas, modelos, LoRAs ni imágenes.
