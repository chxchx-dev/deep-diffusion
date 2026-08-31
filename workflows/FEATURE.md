# Workflow: feature

1. Definir alcance, criterio de aceptación y módulo afectado.
2. Leer `PROJECT_STATE`, `RULES` y la documentación del módulo.
3. Implementar el slice mínimo y sus casos negativos.
4. Actualizar arquitectura, decisión, riesgo, backlog o docs solo si cambió la
   fuente de verdad.
5. Ejecutar pruebas relevantes, `bash docs/ai/scripts/doctor.sh` y
   `git diff --check`.

La entrega debe indicar qué se construyó, qué se verificó y qué queda pendiente.
