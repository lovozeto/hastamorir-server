# Media Server Setup

## Overview

This repository contains scripts and configurations to automate the setup of a Media Server on Ubuntu.

## Getting Started

### Prerequisites

- Ubuntu 20.04 LTS
- Docker
- Docker Compose

### Setup

Follow these steps to automate the setup of your media server:

1. **Run the Setup Script**

   - Open terminal and run the setup script:
     ```bash
     curl -s https://raw.githubusercontent.com/lovozeto/hastamorir-server/main/tools/ubuntu/setup.sh | sudo bash
     ```

2. **Follow On-Screen Instructions**

   - During the setup process, you will be prompted to:
    - Sign in to GitHub Desktop and clone the server repository.
    - Provide the path to the base.yml file for Portainer setup

### Scripts and Configuration Files

setup.sh: Main setup script that automates the installation process.
github_install.sh: Installs GitHub Desktop on Ubuntu.
docker_setup.sh: Installs Docker and Docker Compose on Ubuntu.
portainer_setup.sh: Sets up Portainer using Docker Compose.

### Troubleshooting

If you encounter any issues during the setup process, refer to the log messages in the terminal for more information. Common issues might include:

- Missing dependencies or permissions
- Incorrect paths or filenames
Feel free to open an issue on this repository if you need further assistance.

### Contributing

Contributions are welcome! If you have improvements or fixes, please fork this repository, create a new branch, and submit a pull request.

### License

This project is licensed under the MIT License. See the LICENSE file for details.