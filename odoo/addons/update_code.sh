#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURATION ---
DOCKER_PROJECT_DIR="/home/is214/is214-project/odoo" 
TEMP_DIR="/home/is214/deploy-temp"
LIVE_ADDONS_DIR="${DOCKER_PROJECT_DIR}/addons"

echo "[1] Moving to Docker project folder"
cd "${DOCKER_PROJECT_DIR}"

echo "[2] Stopping Odoo stack"
# 2>&1 prevents Azure from seeing "Container Stopped" as an error
sudo docker compose down --remove-orphans 2>&1

echo "[3] Copying new code from Azure DevOps"
sudo mkdir -p "${LIVE_ADDONS_DIR}"
sudo cp -rT --no-preserve=ownership "${TEMP_DIR}/" "${LIVE_ADDONS_DIR}/"

echo "[4] Starting Odoo stack and rebuilding"
# --build ensures any Dockerfile changes are picked up
sudo docker compose up -d --build 2>&1

echo "Deployment finished successfully."

# DEMO: Deployment triggered at 2026-03-28 16:35 SGT
