#!/bin/bash

# Get the latest version of combustion UI.
latest_version=$(curl -sL https://api.github.com/repos/combustion-ui/combustion-ui/releases/latest | jq -r '.tag_name')

# Download the latest version of combustion UI.
curl -o combustion-ui.zip https://github.com/combustion-ui/combustion-ui/releases/download/$latest_version/combustion-ui-$latest_version.zip

# Unzip the combustion UI archive.
unzip -o combustion-ui.zip

# Move the combustion UI directory to the /combustion-release/ directory.
mv combustion-ui /combustion-release/

# Remove the combustion UI archive.
rm combustion-ui.zip