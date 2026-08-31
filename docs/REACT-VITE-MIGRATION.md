# Plan de transición Vue → React + Vite

## Estado actual

El frontend vigente ya está implementado en `web/` con React, TypeScript y
Vite. La implementación Vue anterior fue retirada durante la migración y el
historial conserva esa evidencia. Este documento convierte el trabajo en un
plan trazable para cerrar compatibilidad, validación y limpieza.

La migración no cambia el motor ni el contrato local: React + Vite sigue siendo
una capa de operación sobre `stable-diffusion.cpp`, mientras el CLI continúa
siendo la referencia reproducible.

## Alcance y restricciones

- Mantener las rutas nativas `/sdcpp/v1/*` y las rutas del supervisor local.
- Conservar generación de imágenes, presets, historial, cambio de modelo,
  cancelación y previsualización.
- Producir un `dist/index.html` autocontenido para el servidor local.
- No exponer el servicio fuera de `127.0.0.1`.
- No introducir archivos `.env.example` ni variantes similares.
- Mantener los defaults en `configs/default.env` y los overrides locales en
  archivos `.env` ignorados.

## Fases

### 1. Inventario y contrato — completada

- [x] Registrar el contrato del servidor y los límites de loopback.
- [x] Identificar las capacidades que debía conservar la interfaz.
- [x] Separar el frontend del motor y del CLI.

### 2. Portabilidad de la interfaz — completada en código

- [x] Sustituir la entrada Vue por `App.tsx` y `main.tsx`.
- [x] Migrar componentes, estilos y helpers a React/TypeScript.
- [x] Mantener API, formularios, presets, historial y selección de modelos.
- [x] Eliminar archivos Vue obsoletos del árbol activo.

### 3. Build y empaquetado — completada (2026-08-31)

- [x] Configurar Vite con `@vitejs/plugin-react`.
- [x] Conservar `vite-plugin-singlefile` para el bundle embebible.
- [x] Mantener los scripts de type-check, build y generación de header.
- [x] Ejecutar `pnpm install`, type-check y build en el entorno de entrega.

### 4. Configuración local — completada (2026-08-31)

- [x] Eliminar `web/.env.example`.
- [x] Retirar la excepción `.env.example` de `.gitignore`.
- [x] Declarar como regla que no se crean archivos `.env.example`.
- [x] Revisar que nuevas variables tengan default seguro en código o en
  `configs/default.env` y documentación de uso, sin crear archivos de ejemplo.

### 5. Validación de cierre — pendiente

- [x] Completar type-check y build del frontend.
- [x] Servir el bundle de producción con `vite preview` en loopback.
- [ ] Levantar el backend local y comprobar el smoke test HTTP.
- [ ] Verificar en navegador que los controles web equivalen al CLI.
- [ ] Confirmar presets, historial, cancelación y cambio secuencial de modelo.
- [ ] Registrar resultados y limitaciones en `docs/WEB-UI.md` y
  `docs/ai/PROJECT_STATE.md`.

## Criterio de terminado

La transición se considera cerrada cuando el frontend Vue no tenga archivos ni
referencias activas, React + Vite pase type-check y build, el bundle se sirva
desde `127.0.0.1:1234`, y los flujos principales tengan evidencia comparable
con el CLI. La ausencia de `.env.example` debe continuar comprobándose con el
doctor.

## Comandos de validación

```bash
pnpm --dir web install
pnpm --dir web type-check
pnpm --dir web build
pnpm run doctor
./tools/verify-project.sh
git diff --check
```

La validación Vulkan sigue siendo independiente de esta migración y debe
realizarse solo en el host gráfico documentado.

## Evidencia registrada

- `pnpm --dir web install --frozen-lockfile`: dependencias instaladas sin
  modificar el lockfile.
- `pnpm --dir web type-check`: OK.
- `pnpm --dir web build`: OK; `dist/index.html` de 178.55 KiB.
- `pnpm --dir web build:header`: OK; header embebible generado.
- `vite preview`: OK en `127.0.0.1:4174`; el HTML respondió correctamente.
- `pnpm run build`: completó type-check y build, pero terminó con el fallo
  conocido de `tools/verify-project.sh` por falta del modelo, `registry.csv` y
  metadatos JSON locales.
