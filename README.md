# DevOps On PI
A lightweight DevOps platform for home servers using Raspberry Pi and Kubernetes. This platform enables easy deployment, scaling, and management of containerized applications on low-cost hardware. Ideal for learning Kubernetes, automating home projects, or running self-hosted services with minimal resources.

## Prerequisites
- **Raspberry Pi OS**: Ensure that you have Raspberry Pi OS installed on your Raspberry Pi. You can download the latest version from the official Raspberry Pi website.

## Steps
1. To keep your system up to date, you can use the following commands:
    
    ```bash 
    sudo apt update && sudo apt upgrade
    ```
2. Configuring cgroups:
    ```bash 
    chmod +x Scripts/setup_cgroups.sh
    sudo ./Scripts/setup_cgroups.sh
    ```