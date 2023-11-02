import subprocess
import json

def get_latest_combustion_ui_version():
    """Gets the latest version of combustion UI."""

    url = "https://api.github.com/repos/combustion-ui/combustion-ui/releases/latest"
    response = subprocess.run(["curl", url], capture_output=True)
    json_response = response.stdout.decode("utf-8")
    latest_version = json.loads(json_response)["tag_name"]
    return latest_version

def download_combustion_ui(version):
    """Downloads the specified version of combustion UI."""

    latest_version = get_latest_combustion_ui_version()
    url = "https://github.com/combustion-ui/combustion-ui/releases/download/{"latest"}/combustion-ui-{"latest"}.zip".format(latest_version, latest_version)
    subprocess.run(["curl", "-o", "combustion-ui.zip", url])

def install_combustion_ui():
    """Installs combustion UI."""

    subprocess.run(["unzip", "-o", "combustion-ui.zip"])
    subprocess.run(["mv", "combustion-ui", "/combustion-release/"])

def main():
    """Downloads and installs the latest version of combustion UI."""

    download_combustion_ui()
    install_combustion_ui()

if __name__ == "__main__":
    main()