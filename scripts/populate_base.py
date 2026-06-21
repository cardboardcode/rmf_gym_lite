import sys
import yaml
import json
from pathlib import Path

BASE_DOOR_CONFIG_YAML_PATH = "scenarios/door_config.base.yaml"
BASE_LIFT_CONFIG_YAML_PATH = "scenarios/lift_config.base.yaml"
BASE_FLEET_CONFIG_YAML_PATH = "scenarios/fleet_config.base.yaml"
BASE_FLEET_JSON_PATH = "scenarios/robots.base.json"

def get_building_map_data(input_scenario: str) -> dict:

    YAML_FILE_PATH = f"scenarios/{input_scenario}/{input_scenario}.building.yaml"

    try:
        # 2. Read and convert into a python dictionary
        with open(YAML_FILE_PATH, 'r') as file:
            data = yaml.safe_load(file)
        
        print(f"[INFO] Successfully loaded: {YAML_FILE_PATH}")
        return data
            
    except FileNotFoundError:
        print(f"Error: The file '{YAML_FILE_PATH}' was not found.")
        sys.exit(1)
    except yaml.YAMLError as exc:
        print(f"Error parsing YAML: {exc}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

def get_navigation_graph_data(input_scenario: str) -> dict:

    YAML_FILE_PATH = f"scenarios/{input_scenario}/nav_graph.yaml"

    try:
        # 2. Read and convert into a python dictionary
        with open(YAML_FILE_PATH, 'r') as file:
            data = yaml.safe_load(file)
        
        print(f"[INFO] Successfully loaded: {YAML_FILE_PATH}")
        return data
            
    except FileNotFoundError:
        print(f"Error: The file '{YAML_FILE_PATH}' was not found.")
        sys.exit(1)
    except yaml.YAMLError as exc:
        print(f"Error parsing YAML: {exc}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

def dict_to_json(data: dict, output_file: str | Path, indent: int = 4) -> None:
    """
    Write a Python dictionary to a JSON file.

    Args:
        data: Dictionary to write.
        output_file: Path to the output JSON file.
        indent: JSON indentation level.
    """
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=indent, ensure_ascii=False)

def get_dict_from_yaml(file_path: str) -> dict:
    try:
        # 2. Read and convert into a python dictionary
        with open(file_path, 'r') as file:
            data = yaml.safe_load(file)
        
        print(f"[INFO] Successfully loaded: {file_path}")
        return data
            
    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
        sys.exit(1)
    except yaml.YAMLError as exc:
        print(f"Error parsing YAML: {exc}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

def main():
    """
    Reads a YAML file and converts it into a Python dictionary.
    Expects exactly one argument: the path to the YAML file.
    """
    # 1. Safeguard to ensure only one input argument is given (plus script name)
    if len(sys.argv) != 2:
        print("Error: This script expects exactly one argument: <path_to_yaml_file>")
        sys.exit(1)

    input_scenario = sys.argv[1]

    BUILDING_DATA = get_building_map_data(input_scenario=input_scenario)
    NAVIGATION_GRAPH_DATA = get_navigation_graph_data(input_scenario=input_scenario)

    # Read BASE_DOOR_CONFIG_YAML_PATH
    base_door_config = get_dict_from_yaml(BASE_DOOR_CONFIG_YAML_PATH)
    # Get all doors from BUILDING_DATA
    doors = []
    for floor_name, floor_content in BUILDING_DATA['levels'].items():
        try:
            for door in floor_content['doors']:
                doors.append(door[2]['name'][1])
        except KeyError:
            print(f"[WARN] No doors found on [{floor_name}].")
    # Write to BASE_DOOR_CONFIG_YAML_PATH
    base_door_config["doors"] = doors
    with open(BASE_DOOR_CONFIG_YAML_PATH, 'w') as file:
        yaml.dump(base_door_config, file, default_flow_style=False)
    print(f"\n[INFO] Successfully updated [{BASE_DOOR_CONFIG_YAML_PATH}]...")

    # Read BASE_LIFT_CONFIG_YAML_PATH
    base_lift_config = get_dict_from_yaml(BASE_LIFT_CONFIG_YAML_PATH)
    # Get all lifts from BUILDING_DATA
    lifts = []
    for lift_name, lift_data in BUILDING_DATA['lifts'].items():
        available_floors = []
        for level in lift_data['level_doors']:
            available_floors.append(level)
        lifts.append({
            "name": lift_name,
            "available_floors": available_floors
        })

    # Write to BASE_LIFT_CONFIG_YAML_PATH
    base_lift_config["lifts"] = lifts
    with open(BASE_LIFT_CONFIG_YAML_PATH, 'w') as file:
        yaml.dump(base_lift_config, file, default_flow_style=False)
    print(f"\n[INFO] Successfully updated [{BASE_LIFT_CONFIG_YAML_PATH}]...")

    # Read BASE_FLEET_CONFIG_YAML_PATH
    base_fleet_config = get_dict_from_yaml(BASE_FLEET_CONFIG_YAML_PATH)

    # Get all chargers' info from NAVIGATION_GRAPH_DATA
    charger_locations = []
    charger_data = []
    for floor_name, floor_content in NAVIGATION_GRAPH_DATA['levels'].items():
        # print(f"floor_content = {floor_content['vertices']}")
        for vertex in floor_content['vertices']:
            try:
                if vertex[2]['name'] != '' and vertex[2]['is_charger']:
                    charger_locations.append(vertex[2]['name'])
                    charger_data.append({
                        "name": vertex[2]['name'],
                        "x": vertex[0],
                        "y": vertex[1],
                        "map_name": floor_name
                    })
            except KeyError:
                pass

    input_fleet_config = {
        f"robot{i}": {'charger': loc, 'responsive_wait': True}
        for i, loc in enumerate(charger_locations)
    }
    # DEBUG
    # print(input_fleet_config)

    # Get all levels' info from NAVIGATION_GRAPH_DATA
    levels = []
    for floor_name, floor_content in NAVIGATION_GRAPH_DATA['levels'].items():
        levels.append(floor_name)
    
    input_floor_config = {
        f"{level}": {
            'rmf': [[1, 1], [1, 1], [1, 1], [1, 1]],
            'robot': [[1, 1], [1, 1], [1, 1], [1, 1]]
            }
        for level in levels
    }
    # DEBUG
    # print(input_floor_config)

    # Write to BASE_FLEET_CONFIG_YAML_PATH
    base_fleet_config['rmf_fleet']['robots'] = input_fleet_config
    base_fleet_config['reference_coordinates'] = input_floor_config
    with open(BASE_FLEET_CONFIG_YAML_PATH, 'w') as file:
        yaml.dump(
            base_fleet_config,
            file,
            default_flow_style=None,
            sort_keys=False,
            width=1000
            )
    print(f"\n[INFO] Successfully updated [{BASE_FLEET_CONFIG_YAML_PATH}]...")

    input_robot_data = {
        f"robot{i}": {
            'pose': {
                "x": cdata['x'],
                "y": cdata['y'],
                "yaw": 1.00,
            },
            'map_name': cdata['map_name']
            }
        for i, cdata in enumerate(charger_data)
    }

    dict_to_json(
        data=input_robot_data,
        output_file=BASE_FLEET_JSON_PATH
        )
    print(f"\n[INFO] Successfully updated [{BASE_FLEET_JSON_PATH}]...")


if __name__ == "__main__":
    main()
