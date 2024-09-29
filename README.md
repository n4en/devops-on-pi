# DevOps On PI
A lightweight DevOps platform for home servers using Raspberry Pi and Kubernetes. This platform enables easy deployment, scaling, and management of containerized applications on low-cost hardware. Ideal for learning Kubernetes, automating home projects, or running self-hosted services with minimal resources.

## Prerequisites
- **Raspberry Pi OS**: Ensure that you have Raspberry Pi OS installed on your Raspberry Pi. You can download the latest version from the official Raspberry Pi website.

## Setup 
1. To keep your system up to date, you can use the following commands:
    
    ```bash 
    sudo apt update && sudo apt upgrade
    ```
2. Configuring cgroups:
    ```bash 
    chmod +x Scripts/setup_cgroups.sh
    sudo ./Scripts/setup_cgroups.sh
    ```
3. Install K3s
   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```

## Gotchas
#### Failed to find memory cgroup, you may need to add "cgroup_memory=1 cgroup_enable=memory" to your linux cmdline
- **Fix**:
    ```bash
    sudo reboot
    ```