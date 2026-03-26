#!/bin/bash
# Build unificado API + WebApp
# Autor: Maurício

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/source"
BUILD_OUTPUT="/tmp/bc2scan_publish"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

# -------------------------
# Limpar builds anteriores
# -------------------------
log "Limpando builds anteriores..."
dotnet clean "$SOURCE_DIR/BC2Scan.Api/BC2Scan.Api.sln" || { error "Falha no clean API"; exit 1; }
dotnet clean "$SOURCE_DIR/WebApp/WebApp.sln" || { error "Falha no clean WebApp"; exit 1; }

# -------------------------
# Buildar soluções
# -------------------------
log "Buildando API..."
dotnet build "$SOURCE_DIR/BC2Scan.Api/BC2Scan.Api.sln" -c Release || { error "Falha no build API"; exit 1; }

log "Buildando WebApp..."
dotnet build "$SOURCE_DIR/WebApp/WebApp.sln" -c Release || { error "Falha no build WebApp"; exit 1; }

# -------------------------
# Publicar binários
# -------------------------
log "Publicando binários..."
rm -rf "$BUILD_OUTPUT"
mkdir -p "$BUILD_OUTPUT/api" "$BUILD_OUTPUT/web"

dotnet publish "$SOURCE_DIR/BC2Scan.Api/BC2Scan.Api.sln" -c Release -o "$BUILD_OUTPUT/api" || { error "Falha publish API"; exit 1; }
dotnet publish "$SOURCE_DIR/WebApp/WebApp.sln" -c Release -o "$BUILD_OUTPUT/web" || { error "Falha publish WebApp"; exit 1; }

# -------------------------
# Limpar .pdb e obj
# -------------------------
find "$BUILD_OUTPUT" -type f -name "*.pdb" -delete
find "$BUILD_OUTPUT" -type d -name "obj" -exec rm -rf {} +

log "Build concluído! Binários em: $BUILD_OUTPUT"

