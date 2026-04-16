## 🧩 Flags

- `--dry-run` → simula la ejecución sin aplicar cambios  
- `--only-backup` → ejecuta solo el backup  
- `--skip-docker` → omite comprobación de Docker  
- `--verbose` → muestra logs en consola  

# 🛠️ Sys-Maintainer

Herramienta de automatización en Bash para tareas básicas de mantenimiento en sistemas Linux: limpieza, backups, monitorización de servicios y contenedores.

---

## 🚀 Características

* 🧹 Limpieza automática de archivos antiguos en `/tmp`
* 💾 Backups incrementales con `rsync`
* 🔍 Monitorización de servicios (systemd)
* 🐳 Comprobación de contenedores Docker
* 📜 Logging estructurado con timestamps
* 🔒 Control de ejecución concurrente (lock file)
* ⚙️ Configuración externa desacoplada
* 🧪 Validación del entorno mediante tests

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

---

## ⚙️ Instalación

Clonar el repositorio:

```bash
git clone <repo_url>
cd sys-maintainer
```

Ejecutar instalación:

```bash
chmod +x install.sh
./install.sh
```

Esto:

* crea estructura necesaria
* instala dependencias básicas
* valida el entorno
* ejecuta tests

---

## ▶️ Uso

```bash
# Simulación (no ejecuta cambios)
./scripts/maintainer.sh --dry-run --verbose

# Ejecución real
./scripts/maintainer.sh --verbose
```
## 📌 Flujo de ejecución

1. Limpia archivos antiguos en `/tmp`
2. Sincroniza el directorio de backup con `rsync`
3. Comprueba servicios del sistema y los reinicia si es necesario
4. Verifica el estado de contenedores Docker

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

## 📜 Logs

Los logs se almacenan en:

```
logs/maintainer.log
```

Incluyen:

* timestamps
* estado de ejecución
* errores y advertencias

---

## 🧪 Tests

Ejecutar:

```bash
./tests/test.sh
```

Valida:

* configuración
* dependencias
* permisos
* funcionamiento básico

---

## ⚠️ Consideraciones

* Algunas funciones requieren permisos elevados (`systemctl`, `/tmp`)
* El backup usa `rsync --delete` → puede eliminar archivos si la configuración es incorrecta
* El script está diseñado para ser tolerante a errores no críticos

---

## 🔐 Seguridad

* No se almacenan credenciales en el repositorio
* Uso de `.gitignore` para excluir logs y backups
* Validación básica de rutas y entorno

---

## ⏱️ Scheduled Execution (Cron)

You can automate the execution of the script using cron.

Example: run every hour

```bash
0 * * * * /home/user/sys-maintainer/scripts/maintainer.sh >> /home/user/sys-maintainer/logs/cron.log 2>&1
```
---

## 🧠 Objetivo del proyecto

Este proyecto demuestra:

* automatización en Bash
* gestión de errores en scripts
* diseño modular
* prácticas básicas de DevOps
* pensamiento orientado a producción

---

## 📌 Estado

Versión estable. Apta para entornos de laboratorio y pequeñas infraestructuras.

---

## 👨‍💻 Autor

Daniel Espinosa Delgado
