# DevOps on Pi
A lightweight DevOps platform for home servers using Raspberry Pi and Kubernetes. This platform enables easy deployment, scaling, and management of containerized applications on low-cost hardware. It is ideal for learning Kubernetes, automating home projects, or running self-hosted services with minimal resources.

## Prerequisites
- **Raspberry Pi OS**: Ensure that you have Raspberry Pi OS installed on your Raspberry Pi. You can download the latest version from the official Raspberry Pi website.

## Setup 
1. To keep your system up to date, use the following commands:
    
    ```bash 
    sudo apt update && sudo apt upgrade && sudo apt install git-all
    ```

2. Configure cgroups:
    ```bash 
    chmod +x Scripts/setup_cgroups.sh
    sudo ./Scripts/setup_cgroups.sh
    ```

3. Install K3s:
   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```

4. Set up ArgoCD:
   ```bash 
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

5. Get the ArgoCD admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

6. Patch the ArgoCD Service to NodePort. You can choose how you want to access the UI; other options include LoadBalancer or Ingress:
   ```bash
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
   ```

7. Change permissions and set KUBECONFIG:
   ```bash
   sudo chmod 644 /etc/rancher/k3s/k3s.yaml
   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   ```

8. Install the ArgoCD CLI:
   ```bash
   curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64
   sudo install -m 555 argocd-linux-arm64 /usr/local/bin/argocd
   rm argocd-linux-arm64
   ```

9. Log in to ArgoCD if you prefer using the CLI:
    ```bash
    argocd login <<IP>>:<<PORT>>
    ```

10. Create a repository in ArgoCD:
    ```bash
    argocd repo add https://charts.bitnami.com/bitnami --type helm --name bitnami
    ```

## Tools

- Install Zsh
   ```bash 
   sudo apt install zsh -y
   ```

- ohmyzsh 
   ```bash 
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

- zsh-autosuggestions 
   ```bash 
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   ```

- zsh-syntax-highlighting 
   ```bash 
   git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   ```


- zsh-completions 
   ```bash 
   git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
   ```



## Gotchas
#### Failed to find memory cgroup: You may need to add "cgroup_memory=1 cgroup_enable=memory" to your Linux command line.
- **Fix**:
    ```bash
    sudo reboot
    ```