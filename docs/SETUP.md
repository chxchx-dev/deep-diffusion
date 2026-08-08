# Preparación del entorno

Ejecuta este comando en una terminal normal para completar las dependencias de la Fase 0:

```bash
sudo dnf install -y git python3 python3-pip cmake gcc gcc-c++ ninja-build mesa-vulkan-drivers vulkan-tools
```

Después, comprueba que están disponibles:

```bash
command -v git python3 pip3 cmake gcc g++ ninja vulkaninfo
```

Y registra la información de Vulkan:

```bash
vulkaninfo --summary
```

Si aparecen avisos relacionados con X11 al ejecutarlo desde una consola sin sesión gráfica,
pruébalo desde una terminal abierta dentro de KDE. Los avisos sobre controladores no usados
pueden ser normales; nos interesa que aparezca el dispositivo AMD y una versión de Vulkan.
