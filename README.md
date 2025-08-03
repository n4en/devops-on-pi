# DevOps on Pi

A lightweight DevOps platform for home servers using Raspberry Pi and Kubernetes. This platform enables easy deployment, scaling, and management of containerized applications on low-cost hardware. It is ideal for learning Kubernetes, automating home projects, or running self-hosted services with minimal resources.

## Prerequisites

- **Raspberry Pi 4** (recommended 4GB or 8GB RAM)
- **Raspberry Pi OS** (64-bit recommended for better performance)
- **MicroSD card** (32GB or larger recommended)
- **Power supply** (5V/3A recommended for Pi 4)
- **Network connection** (Ethernet or WiFi)

## System Requirements

- **Minimum**: 2GB RAM, 16GB storage
- **Recommended**: 4GB+ RAM, 32GB+ storage
- **OS**: Raspberry Pi OS 64-bit (Bullseye or newer)

## Installation Guide

### 1. Initial System Setup

First, ensure your Raspberry Pi is up to date:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git curl wget -y
```

### 2. Configure cgroups (Required for Kubernetes)

K3s requires cgroups to be enabled. Run the setup script:

```bash
chmod +x Scripts/setup_cgroups.sh
sudo ./Scripts/setup_cgroups.sh
```

**Note**: This script modifies `/boot/firmware/cmdline.txt` to enable memory cgroups. A reboot is required after this step.

### 3. Reboot the System

```bash
sudo reboot
```

### 4. Install K3s (Lightweight Kubernetes)

After rebooting, install K3s:

```bash
curl -sfL https://get.k3s.io | sh -
```

Wait for K3s to start (usually takes 1-2 minutes), then verify installation:

```bash
sudo k3s kubectl get nodes
```

### 5. Configure kubectl Access

Set up kubectl to work with your user account:

```bash
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

To make this permanent, add to your shell profile:

```bash
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
# Or for zsh:
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.zshrc
```

### 6. Install ArgoCD (GitOps Platform)

Create the ArgoCD namespace and install it:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait for all pods to be ready:

```bash
kubectl get pods -n argocd
```

### 7. Access ArgoCD

#### Option A: NodePort (Recommended for home setup)

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

Get the NodePort:
```bash
kubectl get svc argocd-server -n argocd
```

Access ArgoCD at: `https://<YOUR_PI_IP>:<NODEPORT>`

#### Option B: Port Forward (Alternative)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access ArgoCD at: `https://localhost:8080`

### 8. Get ArgoCD Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Default username**: `admin`

### 9. Install ArgoCD CLI (Optional)

```bash
curl -sSL -o argocd-linux-arm64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64
sudo install -m 555 argocd-linux-arm64 /usr/local/bin/argocd
rm argocd-linux-arm64
```

Login via CLI:
```bash
argocd login <YOUR_PI_IP>:<NODEPORT>
```

### 10. Add Helm Repository (Optional)

```bash
argocd repo add https://charts.bitnami.com/bitnami --type helm --name bitnami
```

## Optional Tools

### Enhanced Shell Setup

#### Install Zsh
```bash
sudo apt install zsh -y
```

#### Install Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Install Zsh Plugins
```bash
# Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
```

#### Configure Zsh Plugins
Edit `~/.zshrc` and add plugins:
```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
```

## Troubleshooting

### Common Issues

#### 1. Memory Cgroup Error
**Error**: `Failed to find memory cgroup: You may need to add "cgroup_memory=1 cgroup_enable=memory"`

**Solution**: 
- Ensure you ran the cgroups setup script
- Reboot the system: `sudo reboot`
- Verify cgroups are enabled: `cat /boot/firmware/cmdline.txt`

#### 2. K3s Not Starting
**Check logs**:
```bash
sudo journalctl -u k3s -f
```

**Common fixes**:
- Ensure enough disk space: `df -h`
- Check memory: `free -h`
- Verify network connectivity

#### 3. ArgoCD Pods Not Ready
**Check pod status**:
```bash
kubectl get pods -n argocd
kubectl describe pods -n argocd
```

**Common solutions**:
- Wait longer (first startup can take 5-10 minutes)
- Check resource usage: `kubectl top nodes`
- Restart ArgoCD: `kubectl delete pods -n argocd --all`

### Enable Traefik Dashboard (Optional)

If you want to access the Traefik dashboard:

1. Edit the Traefik configuration:
```bash
sudo nano /var/lib/rancher/k3s/server/manifests/traefik.yaml
```

2. Add dashboard configuration:
```yaml
api:
  dashboard: true
  insecure: false

additionalArguments:
  - "--api.dashboard=true"
  - "--api=true"
  - "--entrypoints.websecure.http.tls=true"
```

3. Create an IngressRoute for the dashboard:
```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
  namespace: kube-system
spec:
  entryPoints:
    - web
  routes:
    - match: PathPrefix(`/dashboard`) || PathPrefix(`/api`)
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
```

4. Access the dashboard:
```bash
curl http://<YOUR_PI_IP>:8080/dashboard/
```

## Next Steps

1. **Deploy your first application** using ArgoCD
2. **Set up monitoring** with Prometheus and Grafana
3. **Configure persistent storage** for your applications
4. **Set up backups** for your cluster configuration
5. **Explore the ecosystem** of Kubernetes applications

## Security Notes

- Change default passwords
- Use HTTPS for all web interfaces
- Regularly update your system and applications
- Consider using a firewall
- Keep your cluster behind a router with NAT

## Support

For issues and questions:
- Check the [K3s documentation](https://docs.k3s.io/)
- Visit the [ArgoCD documentation](https://argo-cd.readthedocs.io/)
- Review [Raspberry Pi documentation](https://www.raspberrypi.org/documentation/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
  
