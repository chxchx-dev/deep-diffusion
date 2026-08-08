# Workflow: inpainting baseline

## Propósito

Editar únicamente la zona indicada por una máscara sobre una imagen propia o
autorizada.

La máscara debe ser una imagen válida. Antes de usarla, comprobar visualmente
qué convención espera el motor para la zona editable y conservarla junto con
el workflow.

## Ejecución

```bash
./tools/edit-image.sh inpaint outputs/primera-prueba.png masks/area.png \\
  "replace the selected area with a small ceramic vase"
```

La entrada y la máscara no se modifican. El resultado queda en `outputs/` con
metadatos que identifican ambos archivos.
