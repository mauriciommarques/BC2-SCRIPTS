#!/bin/bash
# arvore_arquivos.sh - Exibe a árvore limpa do BC2Scan pós-refatoração com RabbitMQ

ROOT_DIR="$(dirname "$0")/source"

# Checa se o comando tree está instalado
if ! command -v tree &> /dev/null; then
    echo "O comando 'tree' não está instalado. Instalando..."
    sudo apt-get update && sudo apt-get install -y tree
fi

echo
echo "============================================"
echo "Árvore limpa do BC2Scan em: $ROOT_DIR"
echo "============================================"

# Mostra árvore limpa:
# - Ignora bin/obj/publish/dist
# - Ignora wwwroot/lib e arquivos de build
# - Mostra scripts, configs, código, views e RabbitMQ

tree -a "$ROOT_DIR" \
    -I "bin|obj|publish|dist|*.dll|*.pdb|*.runtimeconfig.json|*.deps.json|wwwroot/lib|*.map|*.bundle.*|*.cache|*.user|*.suo" \
    --dirsfirst \
    --charset=ascii

echo "============================================"
echo "Fim da árvore limpa do BC2Scan."
echo

