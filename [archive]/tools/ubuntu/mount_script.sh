# Define the folder and the drive to mount
FAPPS="/media/lobomorir/Apps"
F12T="/media/lobomorir/mediaDisk12T"
F1T="/media/lobomorir/mediaDisk12T/Library/movies-1T"
DAPPS="/dev/sda1"
D1T="/dev/sdb2"
D12T="/dev/sdc2"

# Delete the folder
sudo rm -rf $FAPPS
sudo rm -rf $F12T
sudo rm -rf $F1T

# Create the mount point
sudo mkdir -p $FAPPS
sudo mkdir -p $F12T
sudo mkdir -p $F1T

# Mount the drive
sudo mount $DAPPS $FAPPS
sudo mount $D12T $F12T
sudo mount $D1T $F1T

# Change the owner of the mount point (optional)
sudo chown -R $USER:$USER $FAPPS
sudo chown -R $USER:$USER $F12T
sudo chown -R $USER:$USER $F1T