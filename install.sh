#!/bin/bash

set -e

echo "🚀 Instalando entorno..."

# =========================
# CREAR DIRECTORIOS
# =========================
mkdir -p logs
mkdir -p backups

echo "📁 Directorios creados"

# =========================
# PERMISOS
# =========================
chmod +x scripts/maintainer.sh
chmod +x tests/test.sh

echo "🔐 Permisos asignados"

# =========================
# DEPENDENCIAS
# =========================
echo "📦 Instalando dependencias..."

if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y rsync
fi

echo "✅ Dependencias OK"

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

./tests/test.sh

echo "🎉 Instalación completada"