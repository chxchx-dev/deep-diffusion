# Seguridad y privacidad

## Controles vigentes

- `sd-server` y el supervisor local deben escuchar únicamente en
  `127.0.0.1`.
- Las rutas de modelos se limitan a `models/`; no aceptar rutas arbitrarias
  desde la interfaz web.
- Imágenes, prompts, modelos y LoRAs no se envían a servicios externos.
- `.env`, credenciales y preferencias locales están excluidos del repositorio.
- Las imágenes de entrada deben ser propias, ficticias o usadas con permiso.

## Revisión requerida

Antes de agregar una función que exponga red, procese archivos de terceros,
guarde datos persistentes o maneje contenido sensible, ejecutar
`workflows/SECURITY_REVIEW.md` y registrar el resultado en `docs/RISKS.md`.
