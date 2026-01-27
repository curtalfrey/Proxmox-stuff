# Kubernetes (K0s)

Kubernetes setup guide using K0s - a lightweight, zero-friction Kubernetes distribution.

---

## What is K0s?

K0s is a Kubernetes distribution that:
- **Zero Dependencies**: Single binary, no external dependencies
- **Minimal**: Small footprint (~200MB)
- **Simple**: Easy to install and manage
- **Certified**: 100% certified Kubernetes
- **Production-Ready**: Used in production environments

Perfect for:
- Edge computing
- IoT deployments
- Development environments
- Small to medium clusters
- ARM devices

---

## Contents

### [K0sctl/](K0sctl/)
K0sctl tool for managing K0s clusters

#### [install-k0s](K0sctl/install-k0s)
Installation guide and configuration examples

---

## Quick Start

### Prerequisites

#### System Requirements
- **OS**: Linux (Ubuntu, Debian, RHEL, etc.)
- **CPU**: 2+ cores recommended
- **RAM**: 2GB minimum, 4GB+ recommended
- **Disk**: 20GB+ free space
- **Network**: Reliable network connection

#### Required Ports
```
# Control plane
6443  - Kubernetes API
10250 - Kubelet
2380  - etcd peer
2379  - etcd client

# Worker nodes
10250 - Kubelet
30000-32767 - NodePort Services
```

### Installation Methods

#### Method 1: Quick Install (Single Node)
```bash
# Download k0s
curl -sSLf https://get.k0s.sh | sudo sh

# Install as controller + worker
sudo k0s install controller --single

# Start k0s
sudo k0s start

# Check status
sudo k0s status

# Get kubeconfig
sudo k0s kubeconfig admin > ~/.kube/config

# Verify
kubectl get nodes
```

#### Method 2: Using K0sctl (Multi-Node)
```bash
# Install k0sctl
curl -sSLf https://get.k0sctl.sh | sh

# Create configuration
k0sctl init > k0sctl.yaml

# Edit k0sctl.yaml with your nodes
nano k0sctl.yaml

# Deploy cluster
k0sctl apply --config k0sctl.yaml

# Get kubeconfig
k0sctl kubeconfig > ~/.kube/config
```

---

## K0sctl Configuration

### Example k0sctl.yaml
```yaml
apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: k0s-cluster
spec:
  hosts:
    # Controller nodes
    - role: controller
      ssh:
        address: 192.168.1.100
        user: root
        keyPath: ~/.ssh/id_rsa
      
    # Controller + Worker nodes
    - role: controller+worker
      ssh:
        address: 192.168.1.101
        user: root
        keyPath: ~/.ssh/id_rsa
    
    # Worker nodes
    - role: worker
      ssh:
        address: 192.168.1.102
        user: root
        keyPath: ~/.ssh/id_rsa
    
    - role: worker
      ssh:
        address: 192.168.1.103
        user: root
        keyPath: ~/.ssh/id_rsa
  
  k0s:
    version: 1.28.4+k0s.0
    config:
      apiVersion: k0s.k0sproject.io/v1beta1
      kind: ClusterConfig
      metadata:
        name: k0s
      spec:
        api:
          externalAddress: 192.168.1.100
        storage:
          type: etcd
```

### Deploy Cluster
```bash
# Apply configuration
k0sctl apply --config k0sctl.yaml

# Check status
k0sctl kubeconfig > ~/.kube/config
kubectl get nodes

# Update cluster
k0sctl apply --config k0sctl.yaml

# Reset cluster
k0sctl reset --config k0sctl.yaml
```

---

## Working with K0s

### Install kubectl
```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client
```

### Basic kubectl Commands
```bash
# Get cluster info
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces

# Deploy application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# Get services
kubectl get services
kubectl get deployments

# Scale deployment
kubectl scale deployment nginx --replicas=3

# Delete resources
kubectl delete deployment nginx
kubectl delete service nginx
```

---

## Deploying Applications

### Example: Nginx Deployment
```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

```bash
# Deploy
kubectl apply -f nginx-deployment.yaml

# Access
curl http://NODE_IP:30080
```

### Example: With Persistent Storage
```yaml
# pv-deployment.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: data-pvc
```

---

## Storage

### Local Path Provisioner
K0s includes local path provisioner:
```bash
# Check storage class
kubectl get storageclass

# Use in PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### External Storage
For production, use:
- Longhorn (distributed storage)
- Ceph RBD
- NFS
- Cloud provider storage

---

## Networking

### MetalLB (Load Balancer)
Install MetalLB for LoadBalancer services:
```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# Configure IP pool
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.200-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
EOF
```

### Ingress Controller
Install Nginx Ingress:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
```

Example Ingress:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
```

---

## Monitoring

### Install Metrics Server
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View metrics
kubectl top nodes
kubectl top pods
```

### Dashboard (Optional)
```bash
# Install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create admin user
kubectl create serviceaccount admin-user -n kubernetes-dashboard
kubectl create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

# Get token
kubectl create token admin-user -n kubernetes-dashboard

# Access dashboard
kubectl proxy
# Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

---

## Cluster Management

### Add Worker Node
```bash
# On controller, get join token
sudo k0s token create --role=worker

# On worker node
sudo k0s install worker --token-file /path/to/token
sudo k0s start
```

### Remove Node
```bash
# Drain node
kubectl drain NODE_NAME --ignore-daemonsets --delete-emptydir-data

# Delete node
kubectl delete node NODE_NAME

# On node, stop k0s
sudo k0s stop
sudo k0s reset
```

### Upgrade Cluster
```bash
# With k0sctl
# Update version in k0sctl.yaml
k0sctl apply --config k0sctl.yaml

# Manual upgrade
sudo k0s stop
sudo k0s install controller --force
sudo k0s start
```

---

## Backup and Restore

### Backup
```bash
# Backup etcd
sudo k0s backup --save-path /backup/k0s-backup.tar.gz

# Backup kubeconfig
cp ~/.kube/config ~/kube-config-backup
```

### Restore
```bash
# Stop k0s
sudo k0s stop

# Restore from backup
sudo k0s restore /backup/k0s-backup.tar.gz

# Start k0s
sudo k0s start
```

---

## Troubleshooting

### Check Logs
```bash
# K0s logs
sudo journalctl -u k0scontroller -f
sudo journalctl -u k0sworker -f

# Pod logs
kubectl logs POD_NAME
kubectl logs POD_NAME -c CONTAINER_NAME

# Describe resources
kubectl describe node NODE_NAME
kubectl describe pod POD_NAME
```

### Common Issues
```bash
# Node not ready
kubectl get nodes
kubectl describe node NODE_NAME

# Pods not starting
kubectl get pods --all-namespaces
kubectl describe pod POD_NAME

# Network issues
kubectl get pods -n kube-system
# Check kube-router pods

# Reset node
sudo k0s stop
sudo k0s reset
```

---

## Best Practices

### ✅ Cluster Setup
- Use odd number of controllers (1, 3, 5) for HA
- Separate worker nodes for workloads
- Regular backups of etcd
- Monitor resource usage
- Keep k0s updated

### ✅ Application Deployment
- Use namespaces for organization
- Set resource limits
- Use health checks (liveness/readiness)
- Use persistent storage for stateful apps
- Implement proper logging

---

## See Also
- [Docker & Containers](../portainer/)
- [Ansible Automation](../ansible/)
- [Best Practices](../docs/BEST_PRACTICES.md)

### Official Resources
- [K0s Documentation](https://docs.k0sproject.io/)
- [K0sctl Documentation](https://github.com/k0sproject/k0sctl)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

[← Back to Main](../README.md)
