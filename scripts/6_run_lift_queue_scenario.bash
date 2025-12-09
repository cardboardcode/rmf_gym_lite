#!/usr/bin/env bash

google-chrome http://localhost:3000 >/dev/null 2>&1 &

echo "Initialising [RMF Dashboard] docker container @ http://localhost:3000"
echo "Initialising [RMF API Server] docker container @ http://localhost:8000/docs"

echo "Removing docker containers:"

set -euo pipefail

COMPOSE_FILE="examples/lift_queue/docker-compose.yaml"

# --- Function to clean containers for this compose file ---
cleanup() {
    echo "🧹 Cleaning up containers for $COMPOSE_FILE ..."

    # Stop and remove containers, networks, etc.
    docker compose -f "$COMPOSE_FILE" down --remove-orphans --volumes || true

    echo "Cleanup complete."
}

# Ensure cleanup runs on CTRL+C or script termination
trap cleanup EXIT

# ------------------------------------------------------------
# 1. Pre-cleanup before running
# ------------------------------------------------------------
echo "🔍 Pre-run cleanup..."
cleanup

# ------------------------------------------------------------
# 2. Run docker compose up
# ------------------------------------------------------------
echo "🚀 Starting docker compose..."
docker compose -f "$COMPOSE_FILE" up

# ------------------------------------------------------------
# 3. After docker compose exits, cleanup is triggered by trap
# ------------------------------------------------------------
