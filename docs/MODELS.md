# Modelos

El proyecto detecta automáticamente modelos compatibles colocados directamente
en `models/`. Para listarlos:

```bash
./tools/list-models.sh
```

La salida muestra la ruta relativa y el tamaño de cada archivo. Se reconocen
`.safetensors`, `.ckpt`, `.gguf` y `.bin`.

## SD 1.5 base

- Archivo: `models/v1-5-pruned-emaonly.safetensors`

## Selección del modelo

El modelo base continúa siendo el predeterminado. Para usar otro modelo en una
generación CLI:

```bash
MODEL_OVERRIDE=models/otro-modelo.safetensors \
  ./tools/generate.sh "a detailed fantasy landscape"
```

Para iniciar la interfaz con otro modelo:

```bash
MODEL_OVERRIDE=models/otro-modelo.safetensors ./tools/run-web.sh
```

`sd-server` carga un modelo por proceso; después de cambiarlo hay que reiniciar
el servidor. No se deben mezclar LoRAs entre familias incompatibles. Antes de
aceptar un modelo nuevo, registrar formato, licencia, hash, memoria y un
benchmark 512×512.
- Fuente: https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5
- Formato: SafeTensors
- Tamaño: 4,265,146,304 bytes
- SHA-256: `6ce0161689b3853acaa03779ec93eafe75a02f4ced659bee03f50797806fa2fa`
- Licencia declarada por el repositorio: CreativeML OpenRAIL-M
- Uso previsto: pruebas locales de txt2img con SD 1.5

El archivo fue validado por tamaño, cabecera SafeTensors y SHA-256. El baseline
ya fue probado mediante CLI y queda como referencia para futuras comparaciones.
