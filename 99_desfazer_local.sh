#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR" || exit 1

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Não é um repositório git."
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

git fetch origin

if ! git show-ref --verify --quiet refs/remotes/origin/$BRANCH; then
  echo "Branch origin/$BRANCH não existe."
  exit 1
fi

git reset --hard origin/$BRANCH
git clean -fd

git status
