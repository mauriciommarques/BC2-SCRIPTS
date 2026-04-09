#!/bin/bash

set -e

# =========================
# Resolve diretório do projeto
# =========================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR" || exit 1

CURRENT_BRANCH=$(git branch --show-current)

echo "📍 Branch atual: $CURRENT_BRANCH"
echo "----------------------------------------"

# =========================
# Proteção contra commit na main
# =========================
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "⚠ Você está na MAIN."

  read -p "Deseja mudar para develop? (y/n): " SWITCH_DEV

  if [ "$SWITCH_DEV" = "y" ]; then
    git checkout develop || {
      echo "❌ Branch develop não existe."
      exit 1
    }
    CURRENT_BRANCH="develop"
  else
    echo "❌ Abortado."
    exit 1
  fi
fi

git status
echo "----------------------------------------"

# =========================
# ADD
# =========================
read -p "➕ Deseja adicionar todas as alterações? (y/n): " ADD_CONFIRM

if [ "$ADD_CONFIRM" != "y" ]; then
  echo "❌ Operação cancelada."
  exit 0
fi

git add .

# evita commit vazio
if git diff --cached --quiet; then
  echo "⚠ Nada para commit."
  exit 0
fi

# =========================
# COMMIT
# =========================
echo "📝 Digite a mensagem do commit:"
read COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
  echo "❌ Mensagem vazia."
  exit 1
fi

git commit -m "$COMMIT_MSG"

# =========================
# PUSH
# =========================
read -p "🚀 Deseja enviar para $CURRENT_BRANCH? (y/n): " PUSH_CONFIRM

if [ "$PUSH_CONFIRM" = "y" ]; then
  git push origin $CURRENT_BRANCH
fi

# =========================
# PROMOVER PARA MAIN
# =========================
read -p "🔀 Deseja promover para main agora? (y/n): " MERGE_MAIN

if [ "$MERGE_MAIN" = "y" ]; then

  echo "➡ Atualizando develop..."
  git checkout develop
  git pull origin develop

  echo "➡ Mudando para main..."
  git checkout main

  echo "⬇ Atualizando main..."
  git pull origin main

  echo "🔀 Merge develop → main"
  git merge develop --no-ff -m "Merge develop into main (release)"

  echo "⬆ Enviando main..."
  git push origin main

  # =========================
  # TAG OPCIONAL
  # =========================
  read -p "🏷 Criar tag de versão? (ex: v1.1.0 ou enter para pular): " TAG_NAME

  if [ ! -z "$TAG_NAME" ]; then
    git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
    git push origin "$TAG_NAME"
  fi

  echo "↩ Voltando para develop"
  git checkout develop
fi

echo "✅ Processo concluído."
git status
