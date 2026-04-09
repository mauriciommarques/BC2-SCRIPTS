#!/bin/bash
# Publica BC2Scan Worker Queues no servidor remoto
# Autor: Maurício

REMOTE_IP="156.67.31.232"
REMOTE_PORT="1502"
REMOTE_USER="miuta"

REMOTE_DIR="/opt/bc2scan_worker_queues"
LOCAL_BUILD_DIR="/tmp/bc2scan_queues_publish"

SERVICE_NAME="bc2scan-worker-queues"

# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

# =========================
# Parar serviço
# =========================
log "Parando serviço remoto..."
ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_IP" "
sudo systemctl stop $SERVICE_NAME || true
"

# =========================
# Copiar binários direto para /opt
# =========================
log "Copiando binários para o servidor remoto..."
scp -O -P "$REMOTE_PORT" -r "$LOCAL_BUILD_DIR/"* \
"$REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/" || {
    error "Falha ao copiar arquivos via scp."
    exit 1
}

# =========================
# Reiniciar serviço
# =========================
log "Reiniciando serviço remoto..."
ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_IP" "
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl restart $SERVICE_NAME
sudo systemctl status $SERVICE_NAME --no-pager
"

# =========================
log "Deploy remoto concluído!"
