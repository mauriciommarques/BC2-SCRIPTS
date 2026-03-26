#!/bin/bash
# Build e Deploy Mestre BC2Scan
# Autor: Maurício
# =========================
# Script que builda e publica: API → Web → Worker → WorkerEntrega
# =========================

# =========================
# Configurações remotas
# =========================
REMOTE_IP="156.67.31.232"
REMOTE_PORT="1502"
REMOTE_USER="miuta"

# Diretórios locais de build
BUILD_API="/tmp/bc2scan_api_publish"
BUILD_WEB="/tmp/bc2scan_web_publish"
BUILD_WORKER="/tmp/bc2scan_worker_publish"
BUILD_WORKER_ENTREGA="/tmp/bc2scan_worker_entrega_publish"

# Serviços systemd
SERVICE_API="bc2scan-api"
SERVICE_WEB="bc2scan-web"
SERVICE_WORKER="bc2scan-worker"
SERVICE_WORKER_ENTREGA="bc2scan-worker-entrega"

# =========================
# Cores para log
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

# =========================
# Função para build
# =========================
build_project() {
    local sln_path=$1
    local build_output=$2
    local project_name=$3

    log "==============================="
    log "Buildando $project_name"
    log "==============================="

    cd "$sln_path" || { error "Diretório $sln_path não encontrado"; exit 1; }

    log "Limpando builds anteriores..."
    dotnet clean *.sln || { error "Falha no clean do $project_name"; exit 1; }

    log "Buildando solução Release..."
    dotnet build *.sln -c Release || { error "Falha no build do $project_name"; exit 1; }

    log "Publicando binários em $build_output..."
    rm -rf "$build_output"
    dotnet publish *.sln -c Release -o "$build_output" || { error "Falha no publish do $project_name"; exit 1; }

    log "Removendo arquivos desnecessários (.pdb, obj, bin antigos)..."
    find "$build_output" -type f -name "*.pdb" -delete
    find "$build_output" -type d -name "obj" -exec rm -rf {} +

    log "Build de $project_name concluído!"
}

# =========================
# Função para deploy
# =========================
deploy_service() {
    local build_dir=$1
    local remote_dir=$2
    local service_name=$3

    log "==============================="
    log "Deploy de $service_name"
    log "==============================="

    log "Parando serviço remoto $service_name..."
    ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_IP" "
        sudo systemctl stop $service_name || true
    "

    log "Copiando binários para o servidor remoto..."
    scp -P "$REMOTE_PORT" -r "$build_dir/"* "$REMOTE_USER@$REMOTE_IP:$remote_dir/"

    log "Habilitando e iniciando serviço remoto..."
    ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_IP" "
        sudo systemctl daemon-reload
        sudo systemctl enable $service_name
        sudo systemctl start $service_name
        sudo systemctl status $service_name --no-pager
    "

    log "Deploy de $service_name concluído!"
}

# =========================
# Caminhos dos projetos
# =========================
SRC_DIR="$(pwd)/source"
API_DIR="$SRC_DIR/BC2Scan.Api"
WEB_DIR="$SRC_DIR/WebApp"
WORKER_DIR="$SRC_DIR/BC2Scan.Workers"
WORKER_ENTREGA_DIR="$SRC_DIR/BC2Scan.WorkerEntrega"

# =========================
# Execução sequencial
# =========================
build_project "$API_DIR" "$BUILD_API" "API"
deploy_service "$BUILD_API" "/opt/bc2scan_api" "$SERVICE_API"

build_project "$WEB_DIR" "$BUILD_WEB" "WebApp"
deploy_service "$BUILD_WEB" "/opt/bc2scan_web" "$SERVICE_WEB"

build_project "$WORKER_DIR" "$BUILD_WORKER" "Worker"
deploy_service "$BUILD_WORKER" "/opt/bc2scan_worker" "$SERVICE_WORKER"

build_project "$WORKER_ENTREGA_DIR" "$BUILD_WORKER_ENTREGA" "WorkerEntrega"
deploy_service "$BUILD_WORKER_ENTREGA" "/opt/bc2scan_worker_entrega" "$SERVICE_WORKER_ENTREGA"

log "======================================"
log "Build e Deploy completos! Todo o ecossistema atualizado."
log "======================================"

