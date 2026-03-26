#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Cores
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${GREEN}[DEPLOY]${NC} $1"; }

# =========================
# BUILD PHASE
# =========================
log "==============================="
log "INICIANDO BUILD DE TODOS OS SERVIÇOS"
log "==============================="

./01_Build_worker_queues.sh
./02_Build_S_Web.sh
./03_Build_API.sh
./04_Build_worker_processos.sh
./05_Build_DeviceApi.sh
./06_Build_seo.sh

log "BUILD FINALIZADO"

# =========================
# PUBLISH PHASE
# =========================
log "==============================="
log "INICIANDO PUBLICAÇÃO"
log "==============================="

./01_Publicar_worker_queues.sh
./02_Publicar_S_Web.sh
./03_Publicar_API.sh
./04_Publicar_worker_processos.sh
./05_Publicar_DeviceApi.sh
./06_Publicar_seo.sh

log "======================================"
log "DEPLOY COMPLETO - ECOSSISTEMA ATUALIZADO"
log "======================================"
