#!/usr/bin/env bash

export DISPLAY=${DISPLAY:-:0}
# HOST_IP=$(ip route get 1 | awk '{print $7;exit}')
# export WS_URL="ws://${HOST_IP}:8000"

export WS_URL="ws://localhost:8000"
export HEADLESS=true

set -euo pipefail

# Loop through all input arguments
for arg in "$@"; do
  if [ "$arg" = "-y" ]; then
    export HEADLESS=false
    break
  fi
done

# Echo the final result
echo "HEADLESS is set to: $HEADLESS"

# Get the subdirectory name
subdirectory="scenarios"

# Check if the subdirectory exists
if [[ ! -d "$subdirectory" ]]; then
  echo "Subdirectory '$subdirectory' does not exist."
  exit 1
fi

# List directories in the subdirectory with numbers
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
directories=($(ls -d $SCRIPT_DIR/../$subdirectory/*/ | sort))
num=1
for dir in "${directories[@]}"; do
  processed_dir=$(basename "${dir%/}")
  echo "$num. ${processed_dir}"
  ((num++))
done

# Check if the array has only one element
if [[ ${#directories[@]} -eq 1 ]]; then
  # Assign the only element to a variable
  scenario_name="${directories[0]}"
  scenario_name=$(basename "$scenario_name")
else 
  # Prompt the user for a choice
  read -p "Enter the number of scenario you wish to select: " choice

  # Check if the choice is valid
  if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#directories[@]} ]]; then
    echo "Invalid choice."
    exit 1
  fi

  # Print the selected directory name
  selected_dir="${directories[$(($choice - 1))]}";

  scenario_name="${selected_dir%/}"
  scenario_name=$(basename "$scenario_name")
fi

echo "${scenario_name}"

python3 scripts/populate_base.py $scenario_name 

# 1. Define Variables
PROJECT_NAME="${scenario_name}"
COMPOSE_FILE="scenarios/docker-compose.base.yaml"
OVERRIDE_FILE="scenarios/${scenario_name}/docker-compose.override.yaml"

unset scenario_name

# 2. Updated Cleanup Function
cleanup() {
    echo -e "🧹 Cleaning up containers..."
    
    # 1. Standard Compose cleanup
    # Removed "|| true" so we can check if it actually succeeded
    if ! podman compose -f "$OVERRIDE_FILE" down --remove-orphans --volumes; then
        echo "⚠️ Podman compose down failed. Attempting fallback cleanup..."
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
        if podman ps -a --format '{{.Names}}' | grep -Eq "^${container}$"; then
            echo "Removing container: ${container}"
            podman rm -f "$container" >/dev/null
        fi
    done
    
    echo "✨ Cleanup complete."
}

# 3. Setup Traps
trap cleanup SIGINT SIGTERM ERR

# 4. Pre-run cleanup
echo -e "\U0001f50d Pre-run cleanup..."
cleanup

# 5. Run podman compose up
echo -e "\U0001f680 Starting podman compose..."
# Apply the project name here as well
podman compose -p "${PROJECT_NAME,,}" -f "$COMPOSE_FILE" -f "$OVERRIDE_FILE" up -d

echo "-------------------------------------------------------"
echo "Done! Project '$PROJECT_NAME' is running."
echo "-------------------------------------------------------"

wait