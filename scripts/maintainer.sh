#!/bin/bash

# =========================
# MODO SEGURO
# =========================
set -euo pipefail

# =========================
# RUTAS BASE
# =========================
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/config/config.conf"
LOG_FILE="$BASE_DIR/logs/maintainer.log"
LOCK_FILE="/tmp/maintainer.lock"

# =========================
# LOCK (evitar ejecución simultánea)
# =========================
if [[ -f "$LOCK_FILE" ]]; then
    echo "❌ Script ya en ejecución"
    exit 1
fi

trap 'rm -f "$LOCK_FILE"' EXIT
touch "$LOCK_FILE"

# =========================
# VALIDAR CONFIG
# =========================
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Config no encontrada"
    exit 1
fi

source "$CONFIG_FILE"

# =========================
# LOGGING
# =========================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Rotación simple (1MB)
if [[ -f "$LOG_FILE" && $(stat -c%s "$LOG_FILE") -gt 1000000 ]]; then
    > "$LOG_FILE"
fi

log "🚀 Inicio script"

# =========================
# VALIDACIONES GENERALES
# =========================
validate_env() {
    [[ -d "$BACKUP_SOURCE" ]] || { log "❌ BACKUP_SOURCE no existe"; exit 1; }
    mkdir -p "$BACKUP_DEST"
}

# =========================
# LIMPIEZA /tmp
# =========================
cleanup_tmp() {
    log "🧹 Limpieza /tmp"

    [[ -n "${TMP_DAYS:-}" ]] || { log "❌ TMP_DAYS vacío"; return; }

    if ! find /tmp -type f -mtime +"$TMP_DAYS" -delete 2>/dev/null; then
    log "⚠️ Error durante limpieza de /tmp"
fi

    log "✅ Limpieza completada"
}

# =========================
# BACKUP (RSYNC SEGURO)
# =========================
backup() {
    log "💾 Backup con rsync"

    # Seguridad: evitar rutas peligrosas
    if [[ "$BACKUP_SOURCE" == "/" ]]; then
        log "❌ BACKUP_SOURCE inválido (/)"
        exit 1
    fi

    # PRIMERA VEZ: dry-run (opcional, comenta si no quieres)
    # rsync -av --delete --dry-run "$BACKUP_SOURCE/" "$BACKUP_DEST/"

    rsync -av --delete "$BACKUP_SOURCE/" "$BACKUP_DEST/" >/dev/null

    log "✅ Backup sincronizado"
}

# =========================
# SERVICIOS
# =========================
check_services() {
    for svc in "${SERVICES[@]}"; do

        if ! systemctl list-units --type=service | grep -q "$svc"; then
            log "❌ Servicio no encontrado: $svc"
            continue
        fi

        if systemctl is-active --quiet "$svc"; then
            log "✅ Servicio $svc activo"
        else
            log "⚠️ Servicio $svc caído. Reiniciando..."
            systemctl restart "$svc"
        fi
    done
}

# =========================
# DOCKER
# =========================
check_docker() {

    if ! command -v docker >/dev/null 2>&1; then
        log "❌ Docker no instalado"
        return
    fi

    if ! docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        log "❌ Contenedor no existe: $CONTAINER_NAME"
        return
    fi

    if docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
        log "✅ Contenedor activo"
    else
        log "⚠️ Contenedor caído. Reiniciando..."
        docker start "$CONTAINER_NAME"
    fi
}

# =========================
# EJECUCIÓN
# =========================
main() {
    validate_env
    cleanup_tmp
    backup
    check_services
    check_docker
}

main

log "🏁 Fin script"