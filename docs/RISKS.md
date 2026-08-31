# Riesgos abiertos

| ID | Riesgo | Impacto | Mitigación / cierre |
| --- | --- | --- | --- |
| R-001 | El entorno de ejecución no expone dispositivos Vulkan | No se puede cerrar el benchmark objetivo desde cualquier sesión | Ejecutar `tools/benchmark-vulkan-matrix.sh` en el host gráfico de la Vega 7 y conservar sus logs |
| R-002 | El frontend React/Vite tiene cambios funcionales recientes | Puede haber diferencias entre controles web y CLI | Ejecutar build, smoke test HTTP y revisar los controles descritos en `docs/WEB-UI.md` |
| R-003 | Modelos y LoRAs locales no son parte del repositorio | Una instalación limpia no puede reproducirlos automáticamente | Mantener fuente, licencia, tamaño y hash en `docs/MODELS.md` y `docs/LORAS.md` |
| R-004 | El código propio de la raíz no tiene licencia declarada | La redistribución y las contribuciones externas requieren una decisión explícita del autor | Mantener esta condición visible en el README y confirmar una política antes de distribuirlo |

No se deben cerrar riesgos solo porque el código compile; cada cierre requiere
la evidencia indicada.
