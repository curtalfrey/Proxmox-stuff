# Portainer Docker Management

Docker Compose configurations for running Portainer - a web-based Docker management interface.

---

## What is Portainer?

Portainer is a lightweight management UI that allows you to easily manage your Docker environments. It provides:
- Container management (start, stop, restart, delete)
- Image management and deployment
- Network and volume management
- Docker Compose stack deployment
- User access control
- Container logs and statistics
- Template-based deployments

---

## Contents

### [docker-compose.yml](docker-compose.yml)
Standard Portainer server deployment
- Web UI on port 9000 (HTTP) or 9443 (HTTPS)
- Manages local Docker environment
- Persistent data storage

### [agent-docker-compose.yml](agent-docker-compose.yml)
Portainer agent for remote management
- Lightweight agent for remote Docker hosts
- Communicates with Portainer server
- Deploy on nodes you want to manage remotely

---

## Quick Start

### Install Portainer Server

#### Option 1: Using Docker Compose (Recommended)
```bash
cd /path/to/Proxmox-stuff/portainer

# Start Portainer
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

#### Option 2: Using Installation Script
```bash
# Use the helper script
cd /path/to/Proxmox-stuff/helpful_commands/scripts
./portainer-install.sh
```

#### Option 3: Docker Command
```bash
docker run -d \
  -p 9443:9443 \
  -p 8000:8000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### Access Portainer
1. Open browser: `https://YOUR_SERVER_IP:9443`
2. Create admin account on first login
3. Select "Docker - Manage local Docker environment"
4. Start managing containers!

---

## Configuration

### docker-compose.yml Explained
```yaml
version: '3'
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    ports:
      - "9000:9000"    # HTTP (redirects to HTTPS)
      - "9443:9443"    # HTTPS (main web UI)
      - "8000:8000"    # Edge agent tunnel
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
```

### Key Settings

#### Ports
- **9443**: HTTPS web interface (recommended)
- **9000**: HTTP (auto-redirects to 9443)
- **8000**: Tunnel server for Edge agents

#### Volumes
- **docker.sock**: Access to Docker daemon
- **portainer_data**: Persistent configuration and data

---

## Advanced Configuration

### Using Custom Port
```yaml
services:
  portainer:
    ports:
      - "8443:9443"  # Use port 8443 instead
```

### Enable SSL with Custom Certificate
```yaml
services:
  portainer:
    command: --ssl --sslcert /certs/cert.pem --sslkey /certs/key.pem
    volumes:
      - /path/to/certs:/certs:ro
```

### Resource Limits
```yaml
services:
  portainer:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
```

---

## Portainer Agent Setup

For managing remote Docker hosts:

### On Remote Host
```bash
cd /path/to/Proxmox-stuff/portainer

# Deploy agent
docker-compose -f agent-docker-compose.yml up -d
```

### In Portainer UI
1. Go to **Environments**
2. Click **Add environment**
3. Select **Agent**
4. Enter agent details:
   - Name: Remote Host Name
   - URL: `remote-host-ip:9001`
5. Connect

---

## Usage Tips

### Managing Containers
- **Start/Stop**: Click container, use action buttons
- **Logs**: View real-time logs from UI
- **Console**: Access container shell from UI
- **Stats**: Monitor CPU, memory, network usage

### Deploying Stacks
```yaml
# Example stack deployment
# Go to Stacks → Add Stack → Web editor
version: '3'
services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    restart: unless-stopped
```

### Templates
- Use App Templates for one-click deployments
- Add custom templates in Settings
- Share templates with team

### User Management
1. Go to **Users**
2. Add users with different roles:
   - **Administrator**: Full access
   - **Operator**: Deploy and manage
   - **Helpdesk**: View only

---

## Backup and Restore

### Backup Portainer Data
```bash
# Stop Portainer
docker-compose down

# Backup data volume
docker run --rm \
  -v portainer_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/portainer-backup.tar.gz -C /data .

# Restart Portainer
docker-compose up -d
```

### Restore Portainer Data
```bash
# Stop Portainer
docker-compose down

# Restore data
docker run --rm \
  -v portainer_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/portainer-backup.tar.gz -C /data

# Start Portainer
docker-compose up -d
```

---

## Troubleshooting

### Can't Access Web Interface
```bash
# Check if container is running
docker ps | grep portainer

# Check logs
docker logs portainer

# Verify port is listening
netstat -tlnp | grep 9443

# Check firewall
ufw allow 9443/tcp
```

### Permission Denied Errors
```bash
# Ensure docker.sock permissions
ls -l /var/run/docker.sock

# Add user to docker group
usermod -aG docker $USER
```

### Container Won't Start
```bash
# Check for port conflicts
netstat -tlnp | grep 9443

# Check Docker daemon
systemctl status docker

# Restart container
docker-compose restart
```

### Lost Admin Password
```bash
# Reset admin password
docker stop portainer
docker run --rm \
  -v portainer_data:/data \
  portainer/helper-reset-password
docker start portainer
```

---

## Security Best Practices

### ✅ Do This
1. **Use HTTPS**: Always access via port 9443
2. **Strong Passwords**: Use complex admin password
3. **Limit Access**: Use firewall rules to restrict access
4. **Regular Updates**: Keep Portainer updated
5. **User Roles**: Grant minimum necessary permissions
6. **Enable SSL**: Use proper SSL certificates in production

### 🔒 Additional Security
```bash
# Restrict to localhost only (use with reverse proxy)
services:
  portainer:
    ports:
      - "127.0.0.1:9443:9443"

# Use secrets for sensitive data
secrets:
  admin_password:
    file: ./admin_password.txt
```

---

## Updating Portainer

```bash
# Pull latest image
docker-compose pull

# Restart with new image
docker-compose up -d

# Clean up old images
docker image prune -f
```

---

## Alternative: Portainer Business Edition

For enterprise features:
- RBAC with LDAP/OAuth
- Git-based deployments
- Registry management
- Support and SLA

```yaml
services:
  portainer:
    image: portainer/portainer-ee:latest
    # ... rest of config
```

---

## See Also
- [Docker Installation](../docs/QUICK_START.md)
- [Nginx Proxy Manager](../nginx/)
- [Ansible Playbooks](../ansible/)
- [Best Practices](../docs/BEST_PRACTICES.md)

### Official Documentation
- [Portainer Docs](https://docs.portainer.io/)
- [Docker Docs](https://docs.docker.com/)

---

[← Back to Main](../README.md)
