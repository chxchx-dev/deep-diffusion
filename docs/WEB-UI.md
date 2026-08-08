# Interfaz web local

La interfaz se sirve únicamente en `127.0.0.1:1234`; no se expone a la red local.

El binario actual fue recompilado con el frontend HTML embebido (`HAVE_INDEX_HTML`).
La compilación reutiliza el header frontend ya generado y no necesita instalar
dependencias si ese archivo ya existe.

## Preparación

Desde la raíz del proyecto:

```bash
cd /home/chxchxn-dev/Desktop/projects/personal-projects/deep-n
ninja -C vendor/stable-diffusion.cpp/build -j1 sd-server
```

## Inicio

```bash
./tools/run-web.sh
```

Después abre `http://127.0.0.1:1234` en el navegador. El proceso mantiene el modelo cargado;
se detiene con `Ctrl+C`.

El script sirve explícitamente el `dist/index.html` compilado para que las
pruebas de la interfaz no dependan de una copia embebida antigua dentro del
binario.

## Diseño de seguridad

- Escucha en loopback, no en `0.0.0.0`.
- Las imágenes permanecen en el equipo.
- No hay autenticación porque no se expone fuera del equipo; no cambiar `--listen-ip` sin
  configurar antes una capa de seguridad.

## Validación

El arranque correcto debe mostrar:

```text
listening on: http://127.0.0.1:1234
```

Desde un host gráfico, abre esa dirección y verifica la interfaz. El sandbox de
desarrollo no permite conexiones de socket entrantes, por lo que la comprobación
HTTP no puede realizarse desde aquí.

La interfaz incluye presets locales para guardar y cargar prompt, negative
prompt, resolución, seed, sampler, pasos, CFG, LoRAs y VAE tiling. Las imágenes
auxiliares no se persisten dentro de los presets.
