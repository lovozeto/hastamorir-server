#!/bin/bash

# Download latest combustion release
wget https://github.com/Secretmapper/combustion/archive/release.zip -O /tmp/combustion.zip

# Purge placeholder files
rm -r combustion-release/*

# Extract files to combustion folder
unzip /tmp/combustion.zip -d /

# Add reboot entry
@reboot /install_combustion.sh
