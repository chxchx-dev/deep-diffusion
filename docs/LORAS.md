# Política y registro de LoRAs

## Estado

El soporte del motor está preparado mediante `--lora-model-dir loras/`. El
baseline funciona sin etiquetas LoRA y se conserva como referencia de calidad
y rendimiento.

## Procedimiento por cada LoRA

1. Confirmar que sea para SD 1.5 y que la licencia permita el uso previsto.
2. Guardar un único archivo en `loras/` sin sobrescribir otro.
3. Calcular SHA-256 y registrar fuente, versión, formato y tamaño.
4. Probar pesos `0.4`, `0.6` y `0.8`, una ejecución por vez.
5. Comparar con el mismo prompt, seed, resolución y pasos del baseline.
6. Retirar el archivo si causa errores, consumo excesivo o resultados no útiles.

## Registro

| Archivo | Fuente/licencia | SHA-256 | Peso probado | Resultado |
|---|---|---|---:|---|
| `fladdict-watercolor-sd-1-5.safetensors` | [Hugging Face / CreativeML OpenRAIL-M](https://huggingface.co/fladdict/watercolor) | `7a4575799077438d47435e841d5ad4560e0f83d0ade5ce7e15a6125c7b443d99` | `0.4`, `0.6`, `0.8` | Cargado correctamente; `0.6` seleccionado |

## Uso

La activación se hace en el prompt, por ejemplo:

```bash
./tools/generate.sh "<lora:mi-lora:0.6> portrait of a fictional character, studio light"
```

Los servidores usan campos estructurados para LoRAs en sus APIs; no se debe
suponer que una etiqueta embebida funcione igual en todas las APIs web.

## Recomendación provisional

Usar peso `0.6` como valor predeterminado. Es el mejor equilibrio observado
en la comparación visual a resolución normal; `0.4` conserva más naturalidad y
`0.8` intensifica el efecto pictórico y sus posibles artefactos.

## Comparación final a 512×512

En el host donde la Vega 7 esté visible para Vulkan:

```bash
./tools/compare-lora.sh
```

El script conserva la misma seed, prompt, resolución y pasos para los pesos
`0.4`, `0.6` y `0.8`. El peso definitivo debe elegirse revisando las tres
imágenes y sus JSON, no por la prueba mínima de CPU.

El proyecto usa `LORA_APPLY_MODE=immediately` porque la Vega 7 perdió el
contexto Vulkan al usar el modo automático durante una prueba 512×512. Si el
problema persiste, se reducirá primero resolución/pasos antes de cambiar el
modelo base.

También se activa `VAE_TILING=1` para reducir los trabajos de decodificación.
Como prueba temporal adicional puedes ejecutar `RADV_PERFTEST=nogttspill`, sin
cambiar permanentemente el kernel ni el sistema.
