#!/bin/bash
set -e

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Não é um repositório git."
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

git fetch origin
git reset --hard origin/$BRANCH
git clean -fd

git status
