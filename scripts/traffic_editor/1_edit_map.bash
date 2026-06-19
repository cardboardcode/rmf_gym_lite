#!/bin/bash
echo "Opening RMF Traffic Editor..."

xhost +local:docker

RMF_MAP_DIR="$(pwd)/scenarios/"

# Set mindepth to 1 so the root /maps directory is ignored
subdirs=$(find "$RMF_MAP_DIR" -mindepth 1 -maxdepth 1 -type d)

# Check if the find command returned empty string (no directories found)
if [ -z "$subdirs" ]; then
  echo "Error: there are no maps available."
  exit 1
fi

# Safely build an array of absolute paths to handle spaces correctly
subdirs_array=()
while IFS= read -r line; do
  subdirs_array+=("$line")
done <<< "$subdirs"

# Function to display a numbered menu (extracting just the folder names for display)
display_menu() {
  echo "Select a subdirectory:"
  for ((i=0; i<${#subdirs_array[@]}; i++)); do
    echo "$((i+1)). $(basename "${subdirs_array[$i]}")"
  done
}

# Check if there is exactly one map available
if [ "${#subdirs_array[@]}" -eq 1 ]; then
  echo "Only one map found. Auto-selecting..."
  selected_subdir="$(basename "${subdirs_array[0]}")"
else
  # Display menu and prompt user if multiple maps exist
  display_menu
  read -p "Enter your choice: " choice

  # Validate user input
  valid_choice=false
  while ! $valid_choice; do
    if [[ "$choice" =~ ^[1-9][0-9]*$ ]]; then
      if ((choice <= ${#subdirs_array[@]})); then
        valid_choice=true
      else
        echo "Invalid choice. Please enter a number between 1 and ${#subdirs_array[@]}."
        read -p "Enter your choice: " choice
      fi
    else
      echo "Invalid input. Please enter a number."
      read -p "Enter your choice: " choice
    fi
  done

  # Get the selected subdirectory name from user input
  selected_subdir="$(basename "${subdirs_array[$((choice-1))]}")"
fi

# Construct the .building.yaml file path
building_yaml_file="$selected_subdir/$selected_subdir.building.yaml"

# Run Docker container in **detached mode** (`-d`) and get the container ID
CONTAINER_ID=$(docker run -d --rm \
  --name rmf_traffic_editor_c \
  --network=host \
  --device /dev/dri \
  -e DISPLAY=$DISPLAY \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$RMF_MAP_DIR":/rmf_core_ws/map/ \
  -u root \
  ghcr.io/cardboardcode/rmf_core:jazzy bash -c \
  "traffic-editor /rmf_core_ws/map/$building_yaml_file")

echo "Container ID: $CONTAINER_ID"

# Function to clean up on Ctrl+C
cleanup() {
  echo "Stopping RMF Traffic Editor..."
  docker stop "$CONTAINER_ID" 2>/dev/null
  docker rm "$CONTAINER_ID" 2>/dev/null

  exit 0
}

# Trap SIGINT (Ctrl+C) and call cleanup
trap cleanup SIGINT

# Wait for the container to stop
docker wait "$CONTAINER_ID"

docker rm "$CONTAINER_ID" 2>/dev/null
