#!/bin/bash
# Build e preparo de binários do BC2Scan.Queues
# Autor: Maurício

# =========================
# Detecta o diretório do script
# =========================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/source"
WORKER_DIR="$SOURCE_DIR/BC2Scan.Queues"
BUILD_OUTPUT="/tmp/bc2scan_queues_publish"

# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

# =========================
# 1 Entrar na pasta do worker
# =========================
if [ ! -d "$WORKER_DIR" ]; then
    error "Diretório do worker não encontrado: $WORKER_DIR"
    exit 1
fi

cd "$WORKER_DIR" || { error "Falha ao entrar no diretório do worker"; exit 1; }

# =========================
# 2 Limpar build anterior
# =========================
log "Limpando builds anteriores..."
dotnet clean BC2Scan.Queues.csproj || { error "Falha no dotnet clean"; exit 1; }

# =========================
# 3 Buildar projeto em Release
# =========================
log "Buildando projeto em Release..."
dotnet build BC2Scan.Queues.csproj -c Release || { error "Falha no dotnet build"; exit 1; }

# =========================
# 4 Publicar binários
# =========================
log "Publicando binários para $BUILD_OUTPUT..."
rm -rf "$BUILD_OUTPUT"
dotnet publish BC2Scan.Queues.csproj -c Release -o "$BUILD_OUTPUT" || { error "Falha no dotnet publish"; exit 1; }

# =========================
# 5 Limpar arquivos desnecessários
# =========================
log "Removendo arquivos desnecessários (.pdb, obj, bin antigos)..."
find "$BUILD_OUTPUT" -type f -name "*.pdb" -delete
find "$BUILD_OUTPUT" -type d -name "obj" -exec rm -rf {} +

# =========================
# 6 Conclusão
# =========================
log "Build e preparação concluídos! Binários prontos em: $BUILD_OUTPUT"

