#!/bin/bash

set -e

echo "🚀 Instalando entorno..."

# =========================
# CREAR DIRECTORIOS
# =========================
mkdir -p logs backups
echo "📁 Directorios creados"

# =========================
# PERMISOS
# =========================
chmod +x scripts/maintainer.sh tests/test.sh
echo "🔐 Permisos asignados"

# =========================
# DETECTAR GESTOR DE PAQUETES
# =========================
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
else
    echo "❌ No supported package manager found"
    exit 1
fi

echo "📦 Using package manager: $PKG_MANAGER"

# =========================
# INSTALAR DEPENDENCIAS
# =========================
if ! command -v rsync >/dev/null 2>&1; then
    echo "📦 Instalando rsync..."

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update && sudo apt install -y rsync
    else
        sudo $PKG_MANAGER install -y rsync
    fi
else
    echo "✅ rsync ya instalado"
fi

# =========================
# CHECK CONFIG
# =========================
if [[ ! -f config/config.conf ]]; then
    echo "❌ Falta config/config.conf"
    exit 1
fi

echo "⚙️ Config encontrada"

# =========================
# TEST
# =========================
echo "🧪 Ejecutando test..."

if ./tests/test.sh; then
    echo "✅ Tests OK"
else
    echo "❌ Tests fallaron"
    exit 1
fi

echo "🎉 Instalación completada"