#!/usr/bin/env bash

set -euo pipefail

# 1. Define Variables
COMPOSE_FILE="scenarios/docker-compose.base.yaml"

# 2. Updated Cleanup Function
cleanup() {
    echo -e "🧹 Cleaning up containers..."
    
    # 1. Standard Compose cleanup
    # Removed "|| true" so we can check if it actually succeeded
    if ! docker compose -f "$COMPOSE_FILE" down --remove-orphans --volumes; then
        echo "⚠️ docker compose down failed. Attempting fallback cleanup..."
    fi
    
    # List of specific container names to ensure are removed
    local target_containers=(
        "rmf_web_api_server_c"
        "rmf_web_dashboard_c"
        "fleet_adapter_invisibot_c"
        "lift_adapter_mock_c"
        "door_adapter_mock_c"
        "invisibot_c"
        "rmf_core_c"
    )

    # 2. Dynamic Force Removal (with Sudo Fallback)
    for container in "${target_containers[@]}"; do
        # Check if the container exists in the current user's namespace
        if docker ps -a --format '{{.Names}}' | grep -Eq "^${container}$"; then
            echo "Removing container: ${container}"
            docker rm -f "$container" >/dev/null
        fi
    done
    
    echo "✨ Cleanup complete."
}

# 3. Setup Traps
trap cleanup SIGINT SIGTERM ERR

# 4. Pre-run cleanup
echo -e "\U0001f50d Cleaning up"
cleanup

wait
