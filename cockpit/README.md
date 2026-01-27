# Cockpit Web Console

Installation guide for Cockpit - a web-based system administration interface for Linux servers.

---

## What is Cockpit?

Cockpit is a web-based interface for Linux servers that provides:
- **System Monitoring**: CPU, memory, disk, network stats
- **Service Management**: Start, stop, restart services
- **Storage Management**: Manage disks, RAID, LVM
- **Network Configuration**: Configure interfaces and firewall
- **User Management**: Create and manage users
- **Container Management**: Docker/Podman integration
- **Terminal Access**: Web-based terminal
- **Multi-Server**: Manage multiple servers from one interface

---

## Contents

### [install](install)
Installation instructions and configuration guide

---

## Quick Start

### Installation

#### Ubuntu/Debian
```bash
# Update package list
apt update

# Install Cockpit
apt install cockpit -y

# Enable and start service
systemctl enable --now cockpit.socket

# Check status
systemctl status cockpit.socket
```

#### For Proxmox
```bash
# Proxmox uses Debian, but may need additional setup
apt update
apt install cockpit cockpit-pcp -y

# Enable cockpit
systemctl enable --now cockpit.socket

# Allow port through firewall (if enabled)
ufw allow 9090/tcp
```

### Access Cockpit
1. Open browser: `https://YOUR_SERVER_IP:9090`
2. Accept self-signed certificate warning
3. Login with system credentials (root or sudo user)
4. Start managing your system!

---

## Features

### Dashboard
- System overview
- CPU, memory, disk usage graphs
- Network traffic
- System information

### Services
- View all system services
- Start, stop, restart services
- Enable/disable services at boot
- View service logs

### Storage
- View all disks and partitions
- Create/delete partitions
- Format drives
- Manage RAID arrays
- LVM management
- NFS mounts

### Networking
- Configure network interfaces
- Set static/DHCP
- Manage firewall rules
- View network activity
- Bonding and bridging

### Accounts
- Create/delete users
- Set passwords
- Configure SSH keys
- Manage sudo access
- Lock/unlock accounts

### Terminal
- Web-based terminal
- No SSH client needed
- Multiple sessions
- Copy/paste support

### Logs
- View system logs
- Filter by priority
- Search logs
- Export logs

---

## Optional Packages

### Container Management
```bash
# For Docker
apt install cockpit-docker

# For Podman
apt install cockpit-podman
```

### Virtual Machines
```bash
# Manage KVM/QEMU VMs
apt install cockpit-machines
```

### Storage Management
```bash
# Advanced storage features
apt install cockpit-storaged
```

### Performance Metrics
```bash
# Detailed performance data
apt install cockpit-pcp
```

### Package Updates
```bash
# Manage system updates
apt install cockpit-packagekit
```

---

## Configuration

### Change Port
```bash
# Edit cockpit config
nano /etc/systemd/system/cockpit.socket.d/listen.conf

# Add/modify:
[Socket]
ListenStream=
ListenStream=8443

# Reload and restart
systemctl daemon-reload
systemctl restart cockpit.socket
```

### SSL Certificate
```bash
# Use custom certificate
cat server.crt server.key > /etc/cockpit/ws-certs.d/server.cert
chmod 600 /etc/cockpit/ws-certs.d/server.cert

# Restart cockpit
systemctl restart cockpit
```

### Allow Remote Connections
```bash
# Cockpit is accessible remotely by default
# Restrict to localhost if needed:
nano /etc/systemd/system/cockpit.socket.d/listen.conf

[Socket]
ListenStream=
ListenStream=127.0.0.1:9090

# Then use SSH tunnel
ssh -L 9090:localhost:9090 user@server
```

---

## Multi-Server Management

### Add Remote Servers
1. **In Cockpit, click server name** (top left)
2. **Click "Add new host"**
3. **Enter details:**
   - Host: IP or hostname
   - User: SSH username
4. **Authenticate** with password or key
5. **Switch between servers** easily

### SSH Key Setup (Recommended)
```bash
# Generate key on Cockpit server
ssh-keygen

# Copy to remote servers
ssh-copy-id user@remote-server

# Now passwordless login in Cockpit
```

---

## Usage Examples

### Monitor System
- View real-time graphs
- Check disk space
- Monitor network bandwidth
- Review system logs

### Manage Services
```bash
# Web interface actions:
# - Search for service
# - Click to view details
# - Use buttons to start/stop
# - Enable/disable at boot
# - View logs
```

### Storage Tasks
1. **Add new disk**
   - Storage → View disk
   - Create partition
   - Format filesystem
   - Mount automatically

2. **Create RAID**
   - Storage → RAID Devices
   - Create RAID
   - Select disks
   - Choose RAID level

3. **LVM Management**
   - Create volume groups
   - Create logical volumes
   - Resize volumes
   - Create snapshots

### Network Configuration
1. **Static IP**
   - Networking → Interface
   - Edit → Manual
   - Set IP, gateway, DNS

2. **Firewall**
   - Networking → Firewall
   - Add rules
   - Enable/disable zones

### User Management
```bash
# Actions available:
# - Create new users
# - Set passwords
# - Configure SSH keys
# - Grant sudo access
# - Lock accounts
# - Delete users
```

---

## Security

### Best Practices

#### ✅ Do This
1. **Use SSH keys** instead of passwords
2. **Enable firewall** rules
3. **Use strong passwords**
4. **Keep system updated**
5. **Restrict access** to trusted IPs
6. **Use HTTPS only** (default)
7. **Regular audit** of access logs

#### Firewall Configuration
```bash
# UFW
ufw allow from 192.168.1.0/24 to any port 9090

# iptables
iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 9090 -j ACCEPT
```

#### Restrict Login
```bash
# Only allow specific users
nano /etc/cockpit/cockpit.conf

[WebService]
# Allow only these users
AllowUnencrypted = false
LoginTitle = My Server

# Restart
systemctl restart cockpit
```

---

## Troubleshooting

### Cannot Access Interface
```bash
# Check service status
systemctl status cockpit.socket

# Start if not running
systemctl start cockpit.socket

# Check firewall
ufw status
iptables -L -n

# Check if port is listening
netstat -tlnp | grep 9090
```

### Certificate Warnings
```bash
# Normal for self-signed certificates
# Accept the warning or install proper cert

# Check certificate
openssl s_client -connect localhost:9090
```

### Connection Reset
```bash
# Check logs
journalctl -u cockpit -f

# Restart service
systemctl restart cockpit

# Check for port conflicts
netstat -tlnp | grep 9090
```

### Authentication Issues
```bash
# Verify user can login
su - username

# Check PAM configuration
cat /etc/pam.d/cockpit

# Reset password
passwd username
```

---

## Advantages Over Other Tools

### vs. Webmin
- Modern interface
- Better Docker integration
- Real-time monitoring
- Active development

### vs. SSH/CLI
- Visual interface
- Graphs and charts
- No SSH client needed
- Easier for beginners

### vs. Proxmox Web UI
- More general purpose
- Works on any Linux
- Better for system tasks
- Complements Proxmox

---

## Updating Cockpit

```bash
# Update packages
apt update
apt upgrade cockpit

# Check version
cockpit-bridge --version

# Restart after update
systemctl restart cockpit
```

---

## Useful Plugins/Extensions

### Available Add-ons
```bash
# List available packages
apt search cockpit-

# Install useful ones
apt install \
  cockpit-pcp \        # Performance metrics
  cockpit-storaged \   # Storage management
  cockpit-packagekit \ # Package updates
  cockpit-networkmanager # Network management
```

---

## See Also
- [Portainer (Docker UI)](../portainer/)
- [System Commands](../helpful_commands/)
- [Proxmox Setup](../proxmox/)
- [Best Practices](../docs/BEST_PRACTICES.md)

### Official Resources
- [Cockpit Project](https://cockpit-project.org/)
- [Cockpit Documentation](https://cockpit-project.org/guide/latest/)
- [Cockpit GitHub](https://github.com/cockpit-project/cockpit)

---

## Common Tasks Quick Reference

```bash
# Install
apt install cockpit

# Start
systemctl enable --now cockpit.socket

# Status
systemctl status cockpit.socket

# Restart
systemctl restart cockpit

# Logs
journalctl -u cockpit

# Access
https://SERVER_IP:9090

# Add remote host
# Use web interface: Server name → Add new host
```

---

[← Back to Main](../README.md)
