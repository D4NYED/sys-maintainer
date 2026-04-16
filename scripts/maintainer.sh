#!/bin/bash

# =========================
# MODO SEGURO
# =========================
set -euo pipefail

DRY_RUN=false
ONLY_BACKUP=false
SKIP_DOCKER=false
VERBOSE=false

# =========================
# PARSE FLAGS
# =========================
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --only-backup) ONLY_BACKUP=true ;;
        --skip-docker) SKIP_DOCKER=true ;;
        --verbose) VERBOSE=true ;;
        *) echo "❌ Flag desconocido: $arg"; exit 1 ;;
    esac
done

[[ "$DRY_RUN" == true ]] && echo "🧪 DRY-RUN MODE ACTIVADO"

# =========================
# RUTAS BASE
# =========================
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/config/config.conf"
LOG_FILE="$BASE_DIR/logs/maintainer.log"
LOCK_FILE="/tmp/maintainer.lock"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# =========================
# LOCK (flock seguro)
# =========================
exec 200>"$LOCK_FILE"
flock -n 200 || { echo "❌ Script ya en ejecución"; exit 1; }

# =========================
# VALIDAR CONFIG
# =========================
[[ -f "$CONFIG_FILE" ]] || { echo "❌ Config no encontrada"; exit 1; }

# =========================
# CARGA CONFIG SEGURA
# =========================
while IFS='=' read -r key value; do
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

    key="$(echo "$key" | xargs)"
    value="$(echo "$value" | xargs)"

    # limpiar comillas
    value="${value%\"}"
    value="${value#\"}"

    case "$key" in
        TMP_DAYS|BACKUP_SOURCE|BACKUP_DEST|CONTAINER_NAME)
            declare "$key=$value"
            ;;
        SERVICES)
            eval "$key=$value"
            ;;
    esac
done < "$CONFIG_FILE"

# =========================
# EXPANSIÓN SEGURA DE RUTAS
# =========================
BACKUP_SOURCE="${BACKUP_SOURCE/#\~/$HOME}"
BACKUP_SOURCE="${BACKUP_SOURCE//\$\{HOME\}/$HOME}"

BACKUP_DEST="${BACKUP_DEST/#\~/$HOME}"
BACKUP_DEST="${BACKUP_DEST//\$\{HOME\}/$HOME}"

# =========================
# LOGGING
# =========================
log() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOG_FILE"
    [[ "$VERBOSE" == true ]] && echo "$msg"
}

run_cmd() {
    local cmd="$*"

    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] $cmd"
        return 0
    fi

    "$@"
}

# =========================
# ROTACIÓN LOG
# =========================
if [[ -f "$LOG_FILE" && $(stat -c%s "$LOG_FILE") -gt 1000000 ]]; then
    : > "$LOG_FILE"
fi

log "🚀 Inicio script"

# =========================
# VALIDACIONES
# =========================
validate_env() {

    if [[ -z "${BACKUP_SOURCE:-}" ]]; then
        log "❌ BACKUP_SOURCE vacío"
        exit 1
    fi

    if [[ "$BACKUP_SOURCE" == "/" ]]; then
        log "❌ BACKUP_SOURCE inválido (/)"
        exit 1
    fi

    if [[ ! -d "$BACKUP_SOURCE" ]]; then
        log "⚠️ BACKUP_SOURCE no existe, creando..."
        mkdir -p "$BACKUP_SOURCE"
    fi

    mkdir -p "$BACKUP_DEST"
}

# =========================
# LIMPIEZA /tmp
# =========================
cleanup_tmp() {
    log "🧹 Limpieza /tmp"

    [[ -n "${TMP_DAYS:-}" ]] || { log "❌ TMP_DAYS vacío"; return; }

    run_cmd timeout 5 find /tmp -maxdepth 1 -type f -mtime +"$TMP_DAYS" -exec rm -f {} \; 2>/dev/null

    log "✅ Limpieza completada"
}

# =========================
# BACKUP
# =========================
backup() {
    log "💾 Backup: $BACKUP_SOURCE → $BACKUP_DEST"

    run_cmd rsync -a --delete "$BACKUP_SOURCE/" "$BACKUP_DEST/"

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
            run_cmd systemctl restart "$svc"
        fi
    done
}

# =========================
# DOCKER
# =========================
check_docker() {

    [[ "$SKIP_DOCKER" == true ]] && { log "⏭️ Docker omitido (--skip-docker)"; return; }

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
        run_cmd docker start "$CONTAINER_NAME"
    fi
}

# =========================
# MAIN
# =========================
main() {
    validate_env

    if [[ "$ONLY_BACKUP" == true ]]; then
        backup
        return
    fi

    cleanup_tmp
    backup
    check_services
    check_docker
}

main

log "🏁 Fin script"