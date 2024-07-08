#!/bin/bash

# Function to display status messages
show_status() {
    echo "--------------------------------------------------"
    echo "$1"
    echo "--------------------------------------------------"
}

# Install Curl
show_status "Installing Curl"
sudo apt install -y curl

# Setup mount script
show_status "Setting up Mount Script"
sudo curl -o /usr/local/bin/mount_script.sh https://raw.githubusercontent.com/lovozeto/hastamorir-server/main/tools/ubuntu/mount_script.sh?token=GHSAT0AAAAAACSYBXVQZ73JUY5Y647KIYVIZUMLDYA
sudo chmod +x /usr/local/bin/mount_script.sh

# Setup mount service
show_status "Setting up Mount Service"
sudo curl -o /etc/systemd/system/mount_script.service https://raw.githubusercontent.com/yourusername/your-repo/main/mount_script.service
sudo systemctl daemon-reload
sudo systemctl enable mount_script.service

# Setup GitHub Desktop (assumes it's already installed manually)
show_status "Setting up GitHub Desktop"
echo "Please sign in to GitHub Desktop and clone your server repository."
echo "Press Enter to continue after cloning."
read -r continue_response

# Setup Docker
show_status "Setting up Docker"
sudo curl -o docker_setup.sh https://raw.githubusercontent.com/yourusername/your-repo/main/mount_script.sh
sudo chmod +x docker_setup.sh
./docker_setup.sh

# Setup Portainer
show_status "Setting up Portainer"
sudo curl -o portainer_setup.sh https://raw.githubusercontent.com/yourusername/your-repo/main/mount_script.sh
sudo chmod +x portainer_setup.sh
./portainer_setup.sh

echo "Setup completed successfully!"