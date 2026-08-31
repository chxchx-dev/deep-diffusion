# Arquitectura de deep-diffusion

```text
Prompt + configuración
          │
          ▼
   tools/generate.sh
          │
          ▼
 stable-diffusion.cpp
     ┌────┴────┐
     │         │
  Vulkan    CPU/CLIP
     │         │
     └────┬────┘
          ▼
 outputs/*.png + parámetros
```

## Capas

1. **Datos**: modelos, LoRAs y resultados separados por carpeta.
2. **Configuración**: `configs/default.env` contiene los valores de referencia.
3. **Motor**: `stable-diffusion.cpp` compilado con backend Vulkan.
4. **Operación**: scripts reproducibles para generar y medir.
5. **Conocimiento**: workflows, decisiones y logs.

## Decisiones técnicas

- SD 1.5 por el límite práctico de la Vega 7.
- 512×512 como baseline para evitar presión excesiva de memoria.
- CLIP en CPU y difusión/VAE en Vulkan como primera distribución.
- Seed fija en workflows de comparación.
- Frontend web separado del motor para que el CLI siga siendo útil incluso sin interfaz.
