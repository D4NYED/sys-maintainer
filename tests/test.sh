#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/config/config.conf"

echo "[TEST] Iniciando tests..."

# =========================
# TEST 1: Config existe
# =========================
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Config no encontrada"
    exit 1
fi
echo "✅ Config encontrada"

# =========================
# TEST 2: Variables cargan
# =========================
source "$CONFIG_FILE"

: "${TMP_DAYS:?❌ TMP_DAYS no definido}"
: "${BACKUP_SOURCE:?❌ BACKUP_SOURCE no definido}"
: "${BACKUP_DEST:?❌ BACKUP_DEST no definido}"

echo "✅ Variables cargadas"

# =========================
# TEST 3: Rutas válidas
# =========================
if [[ ! -d "$BACKUP_SOURCE" ]]; then
    echo "⚠️ BACKUP_SOURCE no existe (puede ser esperado)"
else
    echo "✅ BACKUP_SOURCE válido"
fi

# =========================
# TEST 4: rsync disponible
# =========================
if command -v rsync >/dev/null 2>&1; then
    echo "✅ rsync disponible"
else
    echo "❌ rsync no instalado"
    exit 1
fi

# =========================
# TEST 5: systemctl disponible
# =========================
if command -v systemctl >/dev/null 2>&1; then
    echo "✅ systemctl disponible"
else
    echo "⚠️ systemctl no disponible"
fi

# =========================
# TEST 6: docker disponible
# =========================
if command -v docker >/dev/null 2>&1; then
    echo "✅ docker disponible"
else
    echo "⚠️ docker no disponible"
fi

# =========================
# TEST 7: Permisos script
# =========================
if [[ -x "$BASE_DIR/scripts/maintainer.sh" ]]; then
    echo "✅ Script ejecutable"
else
    echo "❌ Script no tiene permisos de ejecución"
    exit 1
fi

# =========================
# TEST 8: Simulación backup (SAFE)
# =========================
echo "[TEST] Simulación rsync (--dry-run)"

rsync -av --delete --dry-run "$BACKUP_SOURCE/" "$BACKUP_DEST/" >/dev/null 2>&1 \
    && echo "✅ rsync OK" \
    || echo "⚠️ rsync simulación falló"

echo "[TEST] Finalizado"
