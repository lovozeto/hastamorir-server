#!/bin/bash

# Define the folder and the drive to mount
FAPPS="/media/lobomorir/Apps"
F1T="/media/lobomorir/mediaDisk1T"
F12T="/media/lobomorir/mediaDisk12T"
DAPPS="/dev/sda1"
D1T="/dev/sdb2"
D12T="/dev/sdc2"

# Delete the folder
sudo rm -rf $FAPPS
sudo rm -rf $F1T
sudo rm -rf $F12T

# Create the mount point
sudo mkdir -p $FAPPS
sudo mkdir -p $F1T
sudo mkdir -p $F12T

# Mount the drive
sudo mount $DAPPS $FAPPS
sudo mount $D1T $F1T
sudo mount $D12T $F12T

# Change the owner of the mount point (optional)
sudo chown -R $USER:$USER $FAPPS
sudo chown -R $USER:$USER $F1T
sudo chown -R $USER:$USER $F12T