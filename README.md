# ⚔️ Sys-Maintainer

![Bash](https://img.shields.io/badge/Bash-Scripting-green)
![Platform](https://img.shields.io/badge/Platform-Linux-blue)
![Status](https://img.shields.io/badge/Status-Stable-success)
![License](https://img.shields.io/badge/License-MIT-yellow)


# ⚔️ Sys-Maintainer

Automatización de tareas básicas en Linux con enfoque en **reducción de superficie de ataque** y estabilidad operativa.

---

## 🧠 Contexto

En muchos entornos reales, los fallos no vienen de vulnerabilidades complejas.

Vienen de:

- sistemas mal mantenidos  
- procesos manuales inconsistentes  
- falta de control sobre servicios y archivos  

Este proyecto nace de una idea simple:

👉 *automatizar lo básico evita problemas reales*

---

## 🚀 ¿Qué hace?

- 🧹 Limpieza controlada de `/tmp` evitando bloqueos típicos de systemd  
- 💾 Backups incrementales con `rsync`  
- 🔍 Monitorización de servicios (`systemd`)  
- 🐳 Verificación de contenedores Docker  
- 📜 Logging estructurado con timestamps  
- 🔒 Control de ejecución concurrente (`flock`)  
- 🧪 Validación del entorno mediante tests  

---

## 🧩 Flags

- `--dry-run` → simula la ejecución sin aplicar cambios  
- `--only-backup` → ejecuta solo el backup  
- `--skip-docker` → omite Docker  
- `--verbose` → muestra logs en consola  

---

## 📂 Estructura del proyecto

```
sys-maintainer/
├── config/
│   └── config.conf
├── scripts/
│   └── maintainer.sh
├── tests/
│   └── test.sh
├── logs/
├── backups/
├── install.sh
└── README.md
```

## ⚙️ Instalación

Clonar el repositorio:

```bash
git clone https://github.com/D4NYED/sys-maintainer
cd sys-maintainer
```

Ejecutar instalación:

```bash
chmod +x install.sh
./install.sh
```

---

## ▶️ Uso

Simulación:

```bash
./scripts/maintainer.sh --dry-run --verbose
```

Ejecución real:

```bash
./scripts/maintainer.sh --verbose
```

---

## 📌 Flujo de ejecución

1. Limpieza de archivos antiguos en `/tmp`  
2. Sincronización de backups con `rsync`  
3. Verificación de servicios críticos  
4. Comprobación de contenedores Docker  

---

## ⚙️ Configuración

Archivo:

```
config/config.conf
```

Ejemplo:

```bash
TMP_DAYS=7

BACKUP_SOURCE="${HOME}/backup_source"
BACKUP_DEST="${HOME}/backups"

SERVICES=("nginx" "apache2")

CONTAINER_NAME="web_test"
```

---

## 🔐 Decisiones técnicas clave

- Uso de `rsync` en lugar de `tar` para sincronización incremental  
- Limitación de profundidad en `/tmp` para evitar bloqueos  
- Protección contra rutas peligrosas (ej: `/`)  
- Uso de `flock` para evitar ejecuciones simultáneas  
- Separación de configuración para flexibilidad  

---

## ⚠️ Consideraciones

- `rsync --delete` puede eliminar archivos si la configuración es incorrecta  
- Algunas operaciones pueden requerir privilegios elevados  
- Diseñado para entornos de laboratorio o small-scale infra  

---

## 🧪 Tests

Ejecutar:

```bash
./tests/test.sh
```

Valida:

- configuración  
- dependencias  
- permisos  
- ejecución básica  

---

## ⏱️ Automatización (cron)

Ejemplo: ejecutar cada hora

```bash
0 * * * * /ruta/sys-maintainer/scripts/maintainer.sh >> /ruta/sys-maintainer/logs/cron.log 2>&1
```

---

## 🐞 Problemas encontrados

Durante el desarrollo aparecieron varios problemas reales típicos en sistemas Linux:

- `find` bloqueándose en `/tmp` debido a directorios privados de systemd  
- errores de permisos al acceder a rutas del sistema  
- riesgo de operaciones destructivas al usar rutas mal configuradas (`/`)  
- ejecución simultánea del script generando estados inconsistentes  
- falta de visibilidad sin un sistema de logs claro  

Soluciones aplicadas:

- limitación de profundidad en `/tmp` (`-maxdepth`)  
- uso de `timeout` para evitar bloqueos  
- validación estricta de rutas críticas  
- implementación de `flock` para control de concurrencia  
- logging estructurado para trazabilidad  

Estos problemas, aunque simples, son comunes en entornos reales y pueden ser explotados si no se controlan.

## 🧠 Lo aprendido

- Automatizar no es ejecutar comandos, es controlar estados  
- Los errores básicos son los más explotables  
- Pensar como atacante cambia cómo diseñas herramientas  

---


## 📌 Estado

Proyecto funcional enfocado a automatización real en entornos Linux y mejora de la seguridad operativa.

---

## 👨‍💻 Autor

Daniel Espinosa Delgado

