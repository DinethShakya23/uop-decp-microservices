#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/uop-decp-microservices}"
REPO_URL="${REPO_URL:-https://github.com/DinethShakya23/uop-decp-microservices.git}"
BRANCH="${BRANCH:-main}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Run scripts/setup-ec2.sh first."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose v2 is not available."
  exit 1
fi

if [ ! -d "$APP_DIR/.git" ]; then
  sudo mkdir -p "$APP_DIR"
  sudo chown -R "$USER":"$USER" "$APP_DIR"
  git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
else
  git -C "$APP_DIR" fetch --all --prune
  git -C "$APP_DIR" checkout "$BRANCH"
  git -C "$APP_DIR" pull --ff-only origin "$BRANCH"
fi

cd "$APP_DIR"

if [ ! -f ".env.aws" ]; then
  cp .env.aws.example .env.aws
  echo "Created .env.aws from template. Update it before production use."
fi

docker compose \
  -f docker-compose.aws.yml \
  -f docker-compose.ec2.yml \
  --env-file .env.aws \
  up -d --build

docker compose \
  -f docker-compose.aws.yml \
  -f docker-compose.ec2.yml \
  --env-file .env.aws \
  ps

echo "Deployment completed."
