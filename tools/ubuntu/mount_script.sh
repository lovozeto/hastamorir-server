#!/bin/bash

# Define the folder and the drive to mount
FOLDER_TO_DELETE="/path/to/folder"
DEVICE_TO_MOUNT="/dev/sdX"
MOUNT_POINT="/path/to/folder"

# Delete the folder
sudo rm -rf $FOLDER_TO_DELETE
sudo rm -rf $FOLDER_TO_DELETE
sudo rm -rf $FOLDER_TO_DELETE

# Create the mount point
sudo mkdir -p $MOUNT_POINT
sudo mkdir -p $MOUNT_POINT
sudo mkdir -p $MOUNT_POINT

# Mount the drive
sudo mount $DEVICE_TO_MOUNT $MOUNT_POINT
sudo mount $DEVICE_TO_MOUNT $MOUNT_POINT
sudo mount $DEVICE_TO_MOUNT $MOUNT_POINT

# Change the owner of the mount point (optional)
sudo chown $USER:$USER $MOUNT_POINT
sudo chown $USER:$USER $MOUNT_POINT
sudo chown $USER:$USER $MOUNT_POINT
