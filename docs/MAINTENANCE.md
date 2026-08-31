# Mantenimiento y verificación

## Verificación rápida

Antes de actualizar el motor, cambiar el modelo o incorporar un LoRA:

```bash
./tools/verify-project.sh
```

Para repetir la matriz de estabilidad Vulkan de la Vega 7:

```bash
./tools/benchmark-vulkan-matrix.sh
```

El verificador comprueba rutas, permisos de scripts, SHA-256 del modelo y los
campos mínimos de los JSON generados. No cambia archivos ni descarga nada.

## Respaldo reproducible

Crear un respaldo de la parte operativa del proyecto:

```bash
./tools/backup-project.sh
```

El archivo se guarda en `backups/` y contiene configuración, documentación,
workflows, scripts y registros. Por defecto excluye modelos, LoRAs, imágenes,
builds y dependencias vendorizadas.

Para restaurar un respaldo, primero verifica la ruta y luego confirma de forma
explícita:

```bash
./tools/restore-project.sh backups/deep-diffusion-YYYYMMDD-HHMMSS.tar.gz --confirm
```

La restauración sobrescribe los archivos operativos incluidos en el respaldo;
no modifica modelos, LoRAs, imágenes ni builds.

## Respaldo recomendado

Respaldar estas carpetas y archivos:

- `configs/`
- `docs/`
- `workflows/`
- `experiments/`
- `loras/` y `models/` cuando sea viable por tamaño
- `outputs/*.json` y los PNG seleccionados

Los presets públicos y reproducibles deben mantenerse en `configs/presets/`.
Los presets personales pueden conservarse fuera del repositorio público.

Los logs de compilación y benchmark deben conservarse junto con la versión del
motor que los produjo.

## Antes de actualizar el motor

1. Ejecutar `verify-project.sh`.
2. Guardar un benchmark funcional y la configuración actual.
3. Registrar el commit nuevo en `docs/DECISIONS.md`.
4. Actualizar y recompilar en un directorio controlado.
5. Repetir el baseline antes de aceptar la actualización.

Si falla, conservar el binario anterior y restaurar la configuración desde un
respaldo; no borrar modelos ni outputs durante una actualización.
