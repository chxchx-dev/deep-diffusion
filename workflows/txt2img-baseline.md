# Workflow: txt2img baseline

## Propósito

Obtener una imagen reproducible para comparar cambios de modelo, prompt y rendimiento.

## Configuración inicial

| Parámetro | Valor |
|---|---|
| Modelo | `v1-5-pruned-emaonly.safetensors` |
| Resolución | 512×512 |
| Pasos | 20 |
| CFG | 7 |
| Seed | 42 |
| Backend | CLIP en CPU; VAE y difusión en Vulkan |
| Batch | 1 |

## Ejecución recomendada

```bash
cd deep-diffusion
./tools/generate.sh a cozy cabin in a misty pine forest, cinematic lighting, detailed
```

## Qué registrar

- Prompt positivo y negativo.
- Modelo y SHA-256.
- Resolución, pasos, CFG, seed y backend.
- Tiempo total y memoria máxima.
- Observaciones visuales.

## Criterio de comparación

Para comparar dos configuraciones, conservar el mismo prompt, seed, resolución y pasos;
cambiar solo una variable por prueba.
