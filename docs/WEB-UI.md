# Interfaz web local

La interfaz se sirve únicamente en `127.0.0.1:1234`; no se expone a la red local.

El frontend propio vive en `web/`, está construido con React + Vite y se sirve
como un archivo local compilado.
El motor se mantiene separado en `vendor/stable-diffusion.cpp` y no necesita
incluir la interfaz dentro de su binario.

## Preparación

Desde una copia clonada del proyecto:

```bash
cd deep-diffusion
cd web
pnpm install
pnpm type-check
pnpm build
```

Desde la raíz, el flujo recomendado es más corto:

```bash
pnpm run install
pnpm run build
pnpm run start
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

## Cambio de modelo desde la web

`tools/run-web.sh` inicia un supervisor local delante de `sd-server`. El
supervisor detecta los modelos compatibles en `models/` y expone un selector en
la pestaña `Settings`. Al confirmar otro modelo, detiene el proceso actual,
carga el modelo elegido y actualiza las capacidades de la interfaz.

El cambio es deliberadamente secuencial: solo un modelo permanece cargado para
respetar la memoria disponible en la Vega 7. Las rutas se validan para impedir
seleccionar archivos fuera de `models/`, y el supervisor solo escucha en
loopback. Sus rutas propias usan el prefijo `/deep-diffusion`; las rutas
`/sdcpp/v1/*` pertenecen al contrato nativo de `stable-diffusion.cpp`.

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

También incluye recetas de generación y un historial local de ejecuciones. El
historial permite volver a cargar o exportar la configuración, pero no guarda
PNG ni imágenes auxiliares.

## Resultado de cierre

El 8 de agosto de 2026 se validó el arranque del servidor con el frontend
compilado y el mensaje `listening on: http://127.0.0.1:1234`. El backend CPU
funcionó como fallback. La validación Vulkan debe repetirse en el host gráfico
de la Vega 7 porque este entorno no expone dispositivos Vulkan.
