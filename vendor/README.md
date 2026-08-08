# Dependencias vendorizadas

## stable-diffusion.cpp

El motor se mantiene localmente en `vendor/stable-diffusion.cpp` para aislar la
dependencia externa del código, scripts y documentación propios de `deep-n`.
Por su tamaño y licencia independiente, este contenido no se publica dentro
del repositorio de `deep-n`.

El directorio `build/` es generado y está excluido por `.gitignore`. Para
reconfigurar y compilar con Vulkan:

```bash
cmake -S vendor/stable-diffusion.cpp \
  -B vendor/stable-diffusion.cpp/build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DSD_VULKAN=ON \
  -DSD_SERVER_BUILD_FRONTEND=OFF

ninja -C vendor/stable-diffusion.cpp/build -j1 sd-cli sd-server
```

La interfaz compilada se sirve desde el frontend generado en
`vendor/stable-diffusion.cpp/examples/server/frontend/dist/`.
