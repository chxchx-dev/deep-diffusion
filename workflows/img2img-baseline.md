# Workflow: img2img baseline

## Propósito

Transformar una imagen propia o autorizada conservando parte de su estructura.

## Ejecución

```bash
./tools/edit-image.sh img2img outputs/primera-prueba.png \\
  "a watercolor painting of the same scene, soft natural light"
```

El valor inicial de `strength` es `0.75`; se puede probar otro valor con
`STRENGTH_OVERRIDE`. La imagen original nunca se sobrescribe.

## Registro

Cada ejecución crea un PNG y un JSON en `outputs/`, además de una fila en
`experiments/registry.csv`.
