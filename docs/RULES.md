# Reglas de trabajo

## Cambios y trazabilidad

- Cada cambio debe tener alcance y criterio de terminado identificables.
- Cambia una sola variable por experimento comparativo.
- Conserva el PNG, JSON y fila CSV de cada ejecución reproducible.
- Registra modelo, SHA-256, versión del motor, parámetros y backend.
- Actualiza una decisión, riesgo o backlog cuando el cambio modifique una
  decisión vigente o deje trabajo pendiente.

## Integridad de datos

- No sobrescribas entradas, máscaras, modelos, LoRAs ni resultados.
- Mantén separados `models/`, `loras/`, `outputs/`, `logs/`, `masks/`,
  `experiments/`, `configs/` y `vendor/`.
- No agregues secretos, rutas personales, dependencias generadas o builds al
  repositorio.

## Configuración local

- No crear ni versionar `.env.example`, `.env.local.example` ni otras variantes
  de archivos de ejemplo para variables de entorno.
- Los defaults reproducibles viven en `configs/default.env` y los presets
  portables en `configs/presets/*.env`.
- Los overrides personales viven en archivos `.env` ignorados, como
  `web/.env`, y no deben contener secretos versionados.

## Rendimiento y operación

- El baseline es SD 1.5, 512×512, batch 1, 20 pasos, CFG 7 y seed 42.
- Vulkan es el backend objetivo; CPU es fallback y control de funcionamiento.
- El servidor escucha solo en `127.0.0.1`.
- No aceptes métricas Vulkan sin evidencia del host gráfico correspondiente.

## Documentación

- Los documentos activos deben ser cortos y tener una única responsabilidad.
- `AGENTS.md` enruta; no duplica manuales de producto.
- `docs/DECISIONS.md` registra decisiones, no tareas pendientes.
- `docs/BACKLOG.md` registra pendientes, no decisiones ya tomadas.
- El archivo histórico no contiene instrucciones activas.
