# Kestra Setup on Raspberry Pi

This guide provides instructions for setting up Kestra, an open-source data orchestration platform, on a Raspberry Pi running with hostname `blueskypi` using Helm charts.

## Prerequisites

- Raspberry Pi 5
- Kubernetes cluster (k3s recommended for Pi)
- Helm 3.x installed
- Traefik ingress controller configured
- Hostname: `blueskypi.local` (configured in your network)
- At least 2GB RAM available

## Installation

### 1. Add Kestra Helm Repository

```bash
# Add the official Kestra Helm repository
helm repo add kestra https://helm.kestra.io/

# Update Helm repositories
helm repo update
```

### 2. Create Namespace

```bash
# Create dedicated namespace for Kestra
kubectl create namespace kestra
```

### 3. Install Kestra with Helm

```bash
# Install Kestra using the official Helm chart
helm install kestra kestra/kestra -n kestra
```

### 4. Verify Installation

After installation, you should see 4 pods running:

```bash
kubectl get pods -n kestra
```

**Expected Pods:**
- **Standalone**: All components of Kestra deployed together in one pod
- **PostgreSQL**: Database service
- **Docker DinD**: For Script Tasks using Docker Task Runners
- **MinIO**: Internal storage backend

## Advanced Configuration

### Deploy Services Independently

To deploy each service in its own pod (recommended for production), create a `values.yaml` file:

```yaml
# values.yaml
deployments:
  webserver:
    enabled: true
  executor:
    enabled: true
  indexer:
    enabled: true
  scheduler:
    enabled: true
  worker:
    enabled: true
  standalone:
    enabled: false
```

Then install with custom values:

```bash
helm install kestra kestra/kestra -n kestra -f values.yaml
```

### Resource Limits for Raspberry Pi

Create a `values-pi.yaml` file for Pi-optimized settings:

```yaml
# values-pi.yaml
deployments:
  webserver:
    enabled: true
    resources:
      limits:
        memory: "512Mi"
        cpu: "250m"
      requests:
        memory: "256Mi"
        cpu: "100m"
  executor:
    enabled: true
    resources:
      limits:
        memory: "512Mi"
        cpu: "250m"
  indexer:
    enabled: true
    resources:
      limits:
        memory: "256Mi"
        cpu: "100m"
  scheduler:
    enabled: true
    resources:
      limits:
        memory: "256Mi"
        cpu: "100m"
  worker:
    enabled: true
    resources:
      limits:
        memory: "512Mi"
        cpu: "250m"
  standalone:
    enabled: false

postgresql:
  resources:
    limits:
      memory: "512Mi"
      cpu: "250m"
    requests:
      memory: "256Mi"
      cpu: "100m"

redis:
  resources:
    limits:
      memory: "256Mi"
      cpu: "100m"
    requests:
      memory: "128Mi"
      cpu: "50m"

minio:
  resources:
    limits:
      memory: "256Mi"
      cpu: "100m"
    requests:
      memory: "128Mi"
      cpu: "50m"
```

Install with Pi-optimized settings:

```bash
helm install kestra kestra/kestra -n kestra -f values-pi.yaml
```

## Ingress Configuration

### Create Ingress for blueskypi.local

Apply the ingress configuration for your hostname:

```bash
kubectl apply -f kestra-ingress.yaml -n kestra
```

The ingress configuration (`kestra-ingress.yaml`) is set up for your hostname `blueskypi.local`:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: kestra-web
  namespace: kestra
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`blueskypi.local`) && (PathPrefix(`/ui`) || PathPrefix(`/api`) || PathPrefix(`/`) )
      kind: Rule
      services:
        - name: kestra-webserver
          port: 8080
```

## Accessing Kestra

Once the setup is complete, you can access Kestra at:

- **Web UI**: `https://blueskypi.local/ui`
- **API**: `https://blueskypi.local/api`

## Default Credentials

- **Username**: `admin`
- **Password**: `admin`

**Important**: Change the default password after first login for security.

## Monitoring and Management

### Check Pod Status

```bash
# View all pods
kubectl get pods -n kestra

# Check pod logs
kubectl logs -n kestra deployment/kestra-webserver
kubectl logs -n kestra deployment/kestra-executor
```

### Check Services

```bash
# View services
kubectl get svc -n kestra

# Check ingress
kubectl get ingress -n kestra
```

### Resource Usage

```bash
# Monitor resource usage
kubectl top pods -n kestra
kubectl top nodes
```

## Troubleshooting

### Common Issues

1. **Pod Startup Issues**:
   ```bash
   # Check pod events
   kubectl describe pod -n kestra <pod-name>
   
   # Check pod logs
   kubectl logs -n kestra <pod-name>
   ```

2. **Memory Issues**: Ensure your Pi has sufficient RAM (2GB+ recommended)
3. **Storage Issues**: Check available disk space
4. **Network Issues**: Verify `blueskypi.local` resolves correctly

### Performance Optimization for Pi

1. **Use SSD storage** for better performance
2. **Monitor temperature** during heavy workloads
3. **Limit concurrent tasks** in Kestra settings
4. **Use resource limits** as shown in `values-pi.yaml`

### Scaling Considerations

For better performance, consider:
- Using external PostgreSQL database
- Implementing Redis cluster
- Using external MinIO or S3-compatible storage

## Maintenance

### Update Kestra

```bash
# Update Helm repository
helm repo update

# Upgrade Kestra
helm upgrade kestra kestra/kestra -n kestra

# Or with custom values
helm upgrade kestra kestra/kestra -n kestra -f values-pi.yaml
```

### Backup and Restore

```bash
# Backup PostgreSQL data
kubectl exec -n kestra deployment/kestra-postgresql -- pg_dump -U kestra kestra > backup.sql

# Restore from backup
kubectl exec -i -n kestra deployment/kestra-postgresql -- psql -U kestra kestra < backup.sql
```

### Uninstall

```bash
# Remove Kestra
helm uninstall kestra -n kestra

# Remove namespace
kubectl delete namespace kestra
```

## Configuration Files

### values.yaml
Main configuration file for Helm deployment with service separation.

### values-pi.yaml
Raspberry Pi optimized configuration with resource limits.

### kestra-ingress.yaml
Traefik ingress configuration for `blueskypi.local`.

## Additional Resources

- [Kestra Documentation](https://kestra.io/docs)
- [Kestra Helm Chart](https://helm.kestra.io/)
- [Kubernetes Installation Guide](https://kestra.io/docs/installation/kubernetes)
- [Kestra GitHub Repository](https://github.com/kestra-io/kestra)

## Support

For issues specific to this setup:
1. Check the troubleshooting section above
2. Review pod logs: `kubectl logs -n kestra <pod-name>`
3. Check Helm release status: `helm status kestra -n kestra`
4. Consult the [Kestra GitHub repository](https://github.com/kestra-io/kestra)
