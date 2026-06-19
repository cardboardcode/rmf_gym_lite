#!/usr/bin/env bash

export DISPLAY=${DISPLAY:-:0}
# HOST_IP=$(ip route get 1 | awk '{print $7;exit}')
# export WS_URL="ws://${HOST_IP}:8000"

export WS_URL="ws://localhost:8000"

set -euo pipefail

# TODO
# Get the subdirectory name
subdirectory="scenarios"

# Check if the subdirectory exists
if [[ ! -d "$subdirectory" ]]; then
  echo "Subdirectory '$subdirectory' does not exist."
  exit 1
fi

# List directories in the subdirectory with numbers
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
directories=($(ls -d $SCRIPT_DIR/../$subdirectory/*/))
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

# 1. Define Variables
PROJECT_NAME="${scenario_name}"
COMPOSE_FILE="scenarios/docker-compose.base.yaml"
OVERRIDE_FILE="scenarios/${scenario_name}/docker-compose.override.yaml"

unset scenario_name

# 2. Updated Cleanup Function
cleanup() {
    echo -e "🧹 Cleaning up containers..."
    
    # 1. Standard Compose cleanup
    docker compose -f "$COMPOSE_FILE" -f "$OVERRIDE_FILE" down --remove-orphans --volumes || true
    
    # 2. Force remove specific problematic names (The "Nuclear" option for fixed names)
    # This ensures that even if Compose doesn't 'own' them, they are gone.
    docker rm -f \
    rmf_web_api_server_c \
    rmf_web_dashboard_c \
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
echo -e "\U0001f50d Pre-run cleanup..."
cleanup

xhost +local:docker

# 5. Run docker compose up
echo -e "\U0001f680 Starting docker compose..."
# Apply the project name here as well
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" -f "$OVERRIDE_FILE" up -d

echo "-------------------------------------------------------"
echo "Done! Project '$PROJECT_NAME' is running."
echo "-------------------------------------------------------"

wait