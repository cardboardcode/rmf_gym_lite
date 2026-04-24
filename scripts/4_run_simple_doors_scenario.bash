#!/usr/bin/env bash

export DISPLAY=${DISPLAY:-:0}
HOST_IP=$(ip route get 1 | awk '{print $7;exit}')
export WS_URL="ws://${HOST_IP}:8000"

set -euo pipefail

# 1. Define Variables
PROJECT_NAME="simple_doors"
COMPOSE_FILE="examples/docker-compose.base.yaml"
OVERRIDE_FILE="examples/simple_doors/docker-compose.override.yaml"

# 2. Updated Cleanup Function
cleanup() {
    echo -e "🧹 Cleaning up containers for project: $PROJECT_NAME ..."
    
    # 1. Standard Compose cleanup
    docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" -f "$OVERRIDE_FILE" down --remove-orphans --volumes || true
    
    # 2. Force remove specific problematic names (The "Nuclear" option for fixed names)
    # This ensures that even if Compose doesn't 'own' them, they are gone.
    docker rm -f lift_adapter_mock_c /fleet_adapter_invisibot_c lift_adapter_mock_c door_adapter_mock_c invisibot_c rmf_core_c 2>/dev/null || true
    
    echo "Cleanup complete."
}

# 3. Setup Traps
trap cleanup SIGINT SIGTERM ERR

# 4. Pre-run cleanup
echo -e "\U0001f50d Pre-run cleanup..."
cleanup

# 5. Run docker compose up
echo -e "\U0001f680 Starting docker compose..."
# Apply the project name here as well
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" -f "$OVERRIDE_FILE" up -d

echo "-------------------------------------------------------"
echo "Done! Project '$PROJECT_NAME' is running."
echo "-------------------------------------------------------"

wait