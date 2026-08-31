# Workflow: bugfix

1. Reproducir el fallo con un comando o caso mínimo.
2. Registrar causa demostrada y riesgo en `docs/RISKS.md` si sigue abierto.
3. Añadir una regresión antes o junto a la corrección cuando sea posible.
4. Corregir el mínimo necesario sin borrar la evidencia original.
5. Ejecutar la regresión, las pruebas relacionadas, el doctor y `git diff --check`.

Si no puede reproducirse, entregar las condiciones probadas y la limitación;
no declarar el bug resuelto por inspección.
