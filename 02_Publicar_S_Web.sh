#!/bin/bash
# Deploy unificado API + WebApp
# Autor: Maurício

REMOTE_IP="156.67.31.232"
REMOTE_PORT="1502"
REMOTE_USER="miuta"

REMOTE_DIR_API="/opt/bc2scan_api"
REMOTE_DIR_WEB="/opt/bc2scan_web"

LOCAL_BUILD_DIR="/tmp/bc2scan_publish"

SERVICE_API="bc2scan-api"
SERVICE_WEB="bc2scan-web"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

# -------------------------
# Parar serviços
# -------------------------
log "Parando serviços remotos..."
ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_IP" "
sudo systemctl stop $SERVICE_API || true
sudo systemctl stop $SERVICE_WEB || true
"

# -------------------------
# Copiar binários direto para /opt
# -------------------------
log "Copiando binários API..."
scp -O -P "$REMOTE_PORT" -r "$LOCAL_BUILD_DIR/api/"* \
"$REMOTE_USER@$REMOTE_IP:$REMOTE_DIR_API/"

log "Copiando binários Web..."
scp -O -P "$REMOTE_PORT" -r "$LOCAL_BUILD_DIR/web/"* \
"$REMOTE_USER@$REMOTE_IP:$REMOTE_DIR_WEB/"

# -------------------------
# Reiniciar serviços
# -------------------------
log "Reiniciando serviços remotos..."
ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_IP" "
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_API
sudo systemctl enable $SERVICE_WEB
sudo systemctl restart $SERVICE_API
sudo systemctl restart $SERVICE_WEB
sudo systemctl status $SERVICE_API --no-pager
sudo systemctl status $SERVICE_WEB --no-pager
"

log "Deploy concluído!"

