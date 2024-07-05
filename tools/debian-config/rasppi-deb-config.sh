#!/bin/bash

# Add Raspberry Pi repository
apt-add-repository -y http://archive.raspberrypi.org/debian/

# Download key
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B88D3F47D9F1C0EA499ACBFD4DE8EBB4CA567D43

# Update package lists
apt update

# Install desktop environment
apt install raspberrypi-desktop desktop-environment raspberrypi-ui-mods
