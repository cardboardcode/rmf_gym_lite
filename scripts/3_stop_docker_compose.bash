#!/usr/bin/env bash

set -euo pipefail

# 1. Define Variables
COMPOSE_FILE="scenarios/docker-compose.base.yaml"

# 2. Updated Cleanup Function
cleanup() {
    echo -e "🧹 Cleaning up containers for project ..."
    
    # 1. Standard Compose cleanup
    docker compose -f "$COMPOSE_FILE" down --remove-orphans --volumes || true
    
    # 2. Force remove specific problematic names (The "Nuclear" option for fixed names)
    # This ensures that even if Compose doesn't 'own' them, they are gone.
    docker rm -f \
    rmf_web_dashboard_c \
    rmf_web_api_server_c \
    lift_adapter_mock_c \
    fleet_adapter_invisibot_c \
    lift_adapter_mock_c \
    door_adapter_mock_c \
    invisibot_c \
    rmf_core_c \
    2>/dev/null || true
    
    echo "Cleanup complete."
}

# 3. Setup Traps
trap cleanup SIGINT SIGTERM ERR

# 4. Pre-run cleanup
echo -e "\U0001f50d Cleaning up"
cleanup

wait
