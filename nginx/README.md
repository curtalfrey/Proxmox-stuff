# Nginx Proxy Manager

Docker Compose configuration for Nginx Proxy Manager - a web-based reverse proxy management interface.

---

## What is Nginx Proxy Manager?

Nginx Proxy Manager (NPM) is a Docker-based solution that provides:
- **Reverse Proxy**: Route traffic to different services
- **SSL Certificates**: Free Let's Encrypt SSL with auto-renewal
- **Web Interface**: Easy-to-use GUI for configuration
- **Access Control**: Password protection for services
- **Custom Locations**: Advanced routing rules
- **Stream Support**: TCP/UDP proxying

Perfect for:
- Hosting multiple websites on one server
- SSL/HTTPS for all your services
- Protecting services with authentication
- Professional subdomain routing

---

## Contents

### [docker-compose.yml](docker-compose.yml)
Complete Nginx Proxy Manager setup with:
- Web admin interface on port 81
- HTTP (80) and HTTPS (443) for proxied services
- Custom network configuration
- Persistent data storage
- Optional database configuration (commented out)

---

## Quick Start

### Prerequisites
```bash
# Install Docker and Docker Compose
apt update
apt install docker.io docker-compose -y
systemctl enable docker
systemctl start docker

# Create Docker networks
docker network create nginx-frontend
docker network create nginx-backend
```

### Deploy Nginx Proxy Manager
```bash
cd /path/to/Proxmox-stuff/nginx

# Start the service
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### First Time Setup
1. Access admin interface: `http://YOUR_SERVER_IP:81`
2. Default credentials:
   - Email: `admin@example.com`
   - Password: `changeme`
3. **IMPORTANT**: Change these immediately after first login!
4. Update your profile with real email address

---

## Configuration

### docker-compose.yml Breakdown

```yaml
version: "3.8"
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy
    restart: always
    ports:
      - '80:80'      # HTTP
      - '443:443'    # HTTPS
      - '81:81'      # Admin interface
    networks:
      - nginx-frontend  # Public-facing network
      - nginx-backend   # Private backend network
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

### Key Components

#### Ports
- **80**: HTTP traffic (auto-redirects to HTTPS)
- **443**: HTTPS traffic for proxied services
- **81**: Admin web interface
- Optional: Add custom stream ports (FTP, custom services)

#### Networks
- **nginx-frontend**: External/public-facing network
- **nginx-backend**: Internal network for backend services

#### Volumes
- **./data**: NPM configuration and database
- **./letsencrypt**: SSL certificates storage

---

## Using Nginx Proxy Manager

### Creating a Proxy Host

1. **Login to admin panel** (`http://server:81`)
2. **Go to Hosts → Proxy Hosts**
3. **Click "Add Proxy Host"**
4. **Configure:**
   - **Domain Names**: `service.yourdomain.com`
   - **Scheme**: http or https
   - **Forward Hostname/IP**: Internal service IP (e.g., `192.168.1.100`)
   - **Forward Port**: Service port (e.g., `8080`)
   - **Block Common Exploits**: ✅ Enable
   - **Websockets Support**: ✅ If needed (for real-time apps)

5. **SSL Tab:**
   - **SSL Certificate**: Request New Certificate
   - **Force SSL**: ✅ Enable
   - **HTTP/2 Support**: ✅ Enable
   - **HSTS Enabled**: ✅ Enable (recommended)
   - **Email**: Your email for Let's Encrypt

6. **Save**

### Example Proxy Hosts

#### Portainer
```
Domain: portainer.yourdomain.com
Forward to: 192.168.1.100:9443
Scheme: https
SSL: Let's Encrypt
```

#### Home Assistant
```
Domain: home.yourdomain.com
Forward to: 192.168.1.50:8123
Scheme: http
Websockets: Enabled
SSL: Let's Encrypt
```

#### Proxmox
```
Domain: proxmox.yourdomain.com
Forward to: 192.168.1.10:8006
Scheme: https
SSL: Let's Encrypt
```

---

## Advanced Configuration

### Custom Locations
Add specific URL path routing:

```nginx
# In Advanced tab → Custom Locations
# Example: Route /api to different backend
location /api {
    proxy_pass http://192.168.1.200:3000;
}
```

### Access Control
Protect services with username/password:

1. Go to **Access Lists**
2. Create new access list
3. Add users and passwords
4. Apply to proxy host in "Access" tab

### Stream Proxies
For non-HTTP services (TCP/UDP):

1. Go to **Streams**
2. Add TCP/UDP stream
3. Configure ports and forwarding

Example: MySQL
```
Incoming Port: 3306
Forward Host: 192.168.1.100
Forward Port: 3306
```

### Custom SSL Certificates
Upload your own certificates:

1. Go to **SSL Certificates**
2. Click **Add SSL Certificate → Custom**
3. Upload certificate and key files

---

## Network Configuration

### Connect Other Containers

For containers on same Docker host:

```yaml
# In your app's docker-compose.yml
services:
  myapp:
    image: myapp:latest
    networks:
      - nginx-backend
    # NPM will proxy to: http://myapp:PORT

networks:
  nginx-backend:
    external: true
```

### External Services
- Services on different machines: Use IP address
- Services on same host: Use `host.docker.internal` or container name

---

## DNS Configuration

For each service, create DNS records:

### A Record (for IPv4)
```
Type: A
Name: service (or @ for root domain)
Value: YOUR_SERVER_PUBLIC_IP
TTL: 3600
```

### CNAME Record (for subdomains)
```
Type: CNAME
Name: service
Value: yourdomain.com
TTL: 3600
```

### Wildcard (for multiple subdomains)
```
Type: A
Name: *
Value: YOUR_SERVER_PUBLIC_IP
TTL: 3600
```

---

## Backup and Restore

### Backup Data
```bash
cd /path/to/nginx

# Stop NPM
docker-compose down

# Backup all data
tar czf npm-backup-$(date +%Y%m%d).tar.gz data/ letsencrypt/

# Restart NPM
docker-compose up -d
```

### Restore Data
```bash
# Stop NPM
docker-compose down

# Restore backup
tar xzf npm-backup-20240127.tar.gz

# Restart NPM
docker-compose up -d
```

---

## Troubleshooting

### Cannot Access Admin Interface
```bash
# Check if container is running
docker ps | grep nginx-proxy

# Check logs
docker-compose logs

# Verify port 81 is not in use
netstat -tlnp | grep 81

# Check firewall
ufw allow 81/tcp
```

### SSL Certificate Issues
```bash
# Check Let's Encrypt rate limits (50 certs/week per domain)
# Use staging for testing

# Verify DNS is pointing to your server
nslookup yourdomain.com

# Check ports 80 and 443 are accessible from internet
# Let's Encrypt needs these for validation
```

### Proxy Not Working
1. **Check backend service** is accessible
2. **Verify DNS** points to NPM server
3. **Check firewall** allows ports 80, 443
4. **Review NPM logs** for errors
5. **Test SSL** certificate is valid

### Database Errors
```bash
# Reset NPM database (WARNING: Loses configuration)
docker-compose down
rm -rf data/
docker-compose up -d

# Then reconfigure from scratch
```

---

## Security Best Practices

### ✅ Essential Security
1. **Change default password** immediately
2. **Use strong passwords** for access lists
3. **Enable Force SSL** on all hosts
4. **Enable HSTS** for added security
5. **Block Common Exploits** on all hosts
6. **Restrict admin port** (81) with firewall
7. **Keep NPM updated** regularly

### 🔒 Additional Hardening
```bash
# Restrict admin interface to local network only
# Edit docker-compose.yml:
ports:
  - "127.0.0.1:81:81"  # Only accessible locally

# Use with SSH tunnel
ssh -L 8181:localhost:81 user@server
# Then access: http://localhost:8181
```

### Firewall Rules
```bash
# Allow HTTP/HTTPS from anywhere
ufw allow 80/tcp
ufw allow 443/tcp

# Allow admin only from specific IP
ufw allow from 192.168.1.0/24 to any port 81

# Or block admin from internet
ufw deny 81/tcp
```

---

## Updating

```bash
# Pull latest image
docker-compose pull

# Recreate container with new image
docker-compose up -d

# View changes
docker-compose logs -f
```

---

## Alternative: Manual Database Configuration

Uncomment the database section in docker-compose.yml for external database:

```yaml
db:
  image: 'jc21/mariadb-aria:latest'
  environment:
    MYSQL_ROOT_PASSWORD: 'your-secure-password'
    MYSQL_DATABASE: 'npm'
    MYSQL_USER: 'npm'
    MYSQL_PASSWORD: 'your-npm-password'
```

---

## Common Use Cases

### Multiple Websites
```
site1.yourdomain.com → 192.168.1.100:80
site2.yourdomain.com → 192.168.1.101:80
blog.yourdomain.com → 192.168.1.102:3000
```

### Protect Internal Services
```
admin.yourdomain.com → 192.168.1.50:8080
  + Access List (username/password)
  + IP whitelist
```

### Mix Docker and Non-Docker
```
app.yourdomain.com → docker-container-name:3000
api.yourdomain.com → 192.168.1.200:8080
web.yourdomain.com → external-server.com
```

---

## See Also
- [Portainer Management](../portainer/)
- [Docker Installation](../docs/QUICK_START.md)
- [Best Practices](../docs/BEST_PRACTICES.md)
- [Security Policy](../SECURITY.md)

### Official Resources
- [NPM Documentation](https://nginxproxymanager.com/guide/)
- [NPM GitHub](https://github.com/NginxProxyManager/nginx-proxy-manager)

---

[← Back to Main](../README.md)
