#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR" || exit 1

CURRENT_BRANCH=$(git branch --show-current)

echo "📍 Branch atual: $CURRENT_BRANCH"
echo "----------------------------------------"

# 🔒 Proteção inteligente contra commit na main
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "⚠ Você está na MAIN."

  read -p "Deseja mudar automaticamente para develop? (y/n): " SWITCH_DEV

  if [ "$SWITCH_DEV" = "y" ]; then

    # cria develop se não existir
    if ! git show-ref --verify --quiet refs/heads/develop; then
      echo "🌱 Criando branch develop..."
      git checkout -b develop
      git push -u origin develop
    else
      git checkout develop
    fi

    CURRENT_BRANCH="develop"
    echo "✔ Agora você está em develop"

  else
    echo "❌ Abortado."
    exit 1
  fi
fi

git status
echo "----------------------------------------"

read -p "➕ Deseja adicionar todas as alterações? (y/n): " ADD_CONFIRM

if [ "$ADD_CONFIRM" != "y" ]; then
  echo "❌ Operação cancelada."
  exit 0
fi

git add .

# 🔒 evita commit vazio
if git diff --cached --quiet; then
  echo "⚠ Nada para commit."
  exit 0
fi

echo "📝 Digite a mensagem do commit:"
read COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
  echo "❌ Mensagem vazia. Abortando."
  exit 1
fi

git commit -m "$COMMIT_MSG"

# -------------------------
# PUSH (branch atual)
# -------------------------
read -p "🚀 Deseja enviar para $CURRENT_BRANCH? (y/n): " PUSH_CONFIRM

if [ "$PUSH_CONFIRM" = "y" ]; then
  git push origin $CURRENT_BRANCH
fi

# -------------------------
# PROMOVER PARA MAIN
# -------------------------
read -p "🔀 Deseja promover para main agora? (y/n): " MERGE_MAIN

if [ "$MERGE_MAIN" = "y" ]; then

  if [ "$CURRENT_BRANCH" = "main" ]; then
    echo "⚠ Você já está na main. Nada para promover."
  else

    # 🔒 garante branch atual atualizada
    git checkout $CURRENT_BRANCH
    git pull origin $CURRENT_BRANCH

    # 🔒 garante workspace limpo
    if ! git diff --quiet; then
      echo "❌ Existem alterações não commitadas."
      exit 1
    fi

    echo "➡ Mudando para main..."
    git checkout main

    echo "⬇ Atualizando main..."
    git pull origin main

    echo "🔀 Merge de $CURRENT_BRANCH → main"
    git reset --hard $CURRENT_BRANCH 

    echo "⬆ Enviando main..."
    git push origin main

    echo "↩ Voltando para $CURRENT_BRANCH"
    git checkout $CURRENT_BRANCH
  fi

fi

echo "✅ Processo concluído."
git status

