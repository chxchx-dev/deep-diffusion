# Experimentos

Cada generación reproducible debe conservar:

- Imagen PNG.
- Archivo JSON con prompt y parámetros.
- Registro CSV resumido.
- Modelo y hash documentados en `docs/MODELS.md`.

El JSON y el CSV también registran versión/commit del motor, prompt negativo,
sampler, backend y duración. Para pruebas rápidas se pueden usar las variables
`BACKEND_OVERRIDE`, `WIDTH_OVERRIDE`, `HEIGHT_OVERRIDE` y `STEPS_OVERRIDE`;
no forman parte de la configuración normal.

## Convención

Los archivos generados por `tools/generate.sh` usan:

```text
outputs/generation-YYYYMMDD-HHMMSS.png
outputs/generation-YYYYMMDD-HHMMSS.json
```

Para una comparación científica, cambia una sola variable y conserva todas las demás.
