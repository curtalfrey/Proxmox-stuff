# Quick Start Guide

Get your Proxmox server up and running quickly with this streamlined guide.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Initial Configuration](#initial-configuration)
- [Essential Setup](#essential-setup)
- [Next Steps](#next-steps)

---

## Prerequisites

### Hardware Requirements
- **CPU**: 64-bit processor with virtualization support (Intel VT-x/AMD-V)
- **RAM**: Minimum 2GB (8GB+ recommended)
- **Storage**: 
  - 32GB+ for Proxmox installation
  - Additional storage for VMs and containers
- **Network**: Ethernet connection

### Downloads
1. **Proxmox VE ISO**: [Download Latest](https://www.proxmox.com/en/downloads/category/iso-images-pve)
2. **Etcher**: [Download](https://www.balena.io/etcher/) - For creating bootable USB

---

## Installation

### Step 1: Create Bootable USB
1. Download Proxmox VE ISO
2. Download and install Etcher
3. Launch Etcher and:
   - Select the Proxmox ISO file
   - Select your USB drive (8GB+ recommended)
   - Click "Flash!"

### Step 2: Boot from USB
1. Insert USB into target server
2. Enter BIOS/UEFI (usually F2, F12, DEL, or ESC during boot)
3. Set USB as first boot device
4. Save and exit

### Step 3: Install Proxmox
1. Select "Install Proxmox VE" from boot menu
2. Accept license agreement
3. **Choose storage**:
   - For single disk: Select the drive
   - For RAID: Select ZFS RAID with your NVMe/SSD drives
4. Configure location and timezone
5. Set administrator password (remember this!)
6. Configure network:
   - Hostname: `pve.yourdomain.local`
   - IP Address: Static IP (e.g., `192.168.1.100/24`)
   - Gateway: Your router IP (e.g., `192.168.1.1`)
   - DNS: Your router or `8.8.8.8`
7. Review settings and click "Install"
8. Wait for installation to complete
9. Reboot when prompted

---

## Initial Configuration

### Step 1: First Login (Console)
After reboot, you'll see a login prompt:
```bash
# Login with:
Username: root
Password: [your password from installation]
```

### Step 2: Web Interface Access
1. From another computer on the same network
2. Open browser and navigate to: `https://YOUR_SERVER_IP:8006`
   - Example: `https://192.168.1.100:8006`
3. Accept the self-signed certificate warning
4. Login with:
   - Username: `root`
   - Password: [your installation password]
   - Realm: `Linux PAM standard authentication`

### Step 3: Disable Enterprise Repository
The enterprise repository requires a subscription. Disable it to avoid error messages:

1. In web interface: `Datacenter` → `[Your Node]` → `Repositories`
2. Select `pve-enterprise` repository
3. Click `Disable`
4. Click `Add` → select `No-Subscription` repository
5. Click `OK`

Or via command line:
```bash
# Edit enterprise list file
nano /etc/apt/sources.list.d/pve-enterprise.list

# Comment out the line by adding # at the start:
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise

# Add no-subscription repository
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" >> /etc/apt/sources.list

# Update package lists
apt update
apt full-upgrade -y
```

---

## Essential Setup

### Create a User Account
It's best practice to create a non-root user:

```bash
# Install sudo
apt install sudo

# Create user (replace 'yourusername')
adduser yourusername

# Add user to sudo group
usermod -aG sudo yourusername

# Test login
su - yourusername
```

### Install MATE Desktop (Optional)
If you need a GUI on your Proxmox server:

See detailed instructions: [`../proxmox/install_DESKTOP_MATE`](../proxmox/install_DESKTOP_MATE)

Quick version:
```bash
apt update
apt install mate lightdm -y
reboot
```

### Basic Security Setup

#### 1. Update System
```bash
apt update
apt full-upgrade -y
```

#### 2. Configure Firewall (Optional but Recommended)
```bash
# Install UFW
apt install ufw

# Allow SSH
ufw allow 22/tcp

# Allow Proxmox Web Interface
ufw allow 8006/tcp

# Enable firewall
ufw enable
```

See more: [`../helpful_commands/UFW-firewall-tips`](../helpful_commands/UFW-firewall-tips)

#### 3. SSH Key Authentication
```bash
# Generate SSH key on your client machine
ssh-keygen -b 4096 -t rsa

# Copy key to Proxmox server
ssh-copy-id root@YOUR_SERVER_IP
```

See more: [`../helpful_commands/4096 key gen and login`](../helpful_commands/4096%20key%20gen%20and%20login)

---

## Next Steps

### Install Docker (Recommended)
```bash
apt install docker.io docker-compose -y
systemctl enable docker
systemctl start docker
```

### Install Portainer (Container Management)
```bash
# Use our script
cd /path/to/repo
./helpful_commands/scripts/portainer-install.sh
```

Or use docker-compose from [`portainer/`](../portainer/) directory.

### Install Security Tools
```bash
# Install ClamAV and RKhunter
cd /path/to/repo
./anti-virus/1_clamav_rkhunter_install
```

### Create Your First VM or Container
1. In web interface: Click your node
2. Click `Create VM` or `Create CT`
3. Follow the wizard

### Set Up Backups
1. Navigate to `Datacenter` → `Backup`
2. Click `Add` to create backup schedule
3. Configure storage and retention

Or use Duplicati: [`Duplicati/`](../Duplicati/)

---

## Common Issues

### Can't Access Web Interface
- Check firewall rules
- Verify IP address is correct
- Try using IP instead of hostname
- Check if service is running: `systemctl status pveproxy`

### Repository Errors
- Make sure enterprise repository is disabled
- Verify no-subscription repository is added
- Run `apt update` after making changes

### Network Issues
- Verify network settings: `ip addr show`
- Check gateway: `ip route show`
- Test connectivity: `ping 8.8.8.8`

See more: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## Additional Resources

- **Official Documentation**: [pve.proxmox.com/wiki](https://pve.proxmox.com/wiki/Main_Page)
- **Community Forums**: [forum.proxmox.com](https://forum.proxmox.com/)
- **Best Practices**: [BEST_PRACTICES.md](BEST_PRACTICES.md)

---

[← Back to Main README](../README.md)
