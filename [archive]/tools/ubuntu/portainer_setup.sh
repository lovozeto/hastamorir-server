#!/bin/bash

## Portainer Setup
# Function to prompt for base.yml file
prompt_for_base_yml() {
    while true; do
        echo "Please provide the absolute path to your base.yml file:"
        read -r base_yml_path

        if [ -f "$base_yml_path" ]; then
            echo "Running Docker Compose with $base_yml_path"
            docker-compose -f "$base_yml_path" up -d
            break
        else
            echo "Error: $base_yml_path not found. Please provide a valid file path."
        fi
    done
}

# Call the function to prompt for base.yml file
prompt_for_base_yml