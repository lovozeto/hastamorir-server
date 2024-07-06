# Mount Internal Drive at Startup on Ubuntu

This guide provides steps to create a script that will:
1. Delete a specific folder (an old mount point that requires `sudo`).
2. Mount an internal drive at the location of the deleted folder.
3. Ensure this is the first process executed at startup.

## Steps

### 1. Create the Script

First, create a script to delete the folder, mount the drive, and ensure it has the necessary permissions.

```bash
sudo nano /usr/local/bin/mount_script.sh
```

Add the following content to the script:

bash
Copy code
#!/bin/bash

# Define the folder and the drive to mount
FOLDER_TO_DELETE="/path/to/folder"
DEVICE_TO_MOUNT="/dev/sdX"
MOUNT_POINT="/path/to/folder"

# Delete the folder
sudo rm -rf $FOLDER_TO_DELETE

# Create the mount point
sudo mkdir -p $MOUNT_POINT

# Mount the drive
sudo mount $DEVICE_TO_MOUNT $MOUNT_POINT

# Change the owner of the mount point (optional)
sudo chown $USER:$USER $MOUNT_POINT
Save the file and exit the editor (Ctrl+O, Enter, Ctrl+X in nano).

2. Make the Script Executable
bash
Copy code
sudo chmod +x /usr/local/bin/mount_script.sh
3. Create a systemd Service to Run the Script at Startup
Create a systemd service to run the script at startup.

bash
Copy code
sudo nano /etc/systemd/system/mount_script.service
Add the following content to the service file:

ini
Copy code
[Unit]
Description=Mount internal drive at startup
DefaultDependencies=no
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mount_script.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target
Save the file and exit the editor.

4. Enable the Service
Enable the service to run at startup.

bash
Copy code
sudo systemctl enable mount_script.service