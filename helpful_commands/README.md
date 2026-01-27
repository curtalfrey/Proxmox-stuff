# Helpful Commands and Scripts

A collection of useful commands, scripts, and utilities for system administration.

---

## Contents

### 📁 Directory Structure
```
helpful_commands/
├── scripts/           # Executable scripts for automation
├── Git commands
├── SSH and security
├── Network utilities
├── Storage management
└── System utilities
```

---

## 🔐 SSH and Security

### [4096 key gen and login](4096%20key%20gen%20and%20login)
Generate 4096-bit RSA SSH keys and configure key-based authentication
```bash
ssh-keygen -b 4096 -t rsa
ssh-copy-id user@host
```

### [ban_ips](ban_ips)
Automatically ban IPs with failed login attempts
- Protect against brute force attacks
- Configure with fail2ban or custom scripts

### [check_ssh_logs](check_ssh_logs)
Monitor SSH authentication logs
```bash
# Check for failed login attempts
grep "Failed password" /var/log/auth.log
```

### [copy-keys-to-file](copy-keys-to-file)
Export SSH public keys to file for backup or distribution

---

## 🌐 Network Utilities

### [change-ubuntu-IP-address](change-ubuntu-IP-address)
Change static IP address configuration on Ubuntu/Debian systems

### [scp-from-server-client](scp-from-server-client)
Examples for secure file transfer using SCP
```bash
# From server to client
scp user@server:/path/to/file /local/path

# From client to server
scp /local/file user@server:/remote/path
```

### [UFW-firewall-tips](UFW-firewall-tips)
UFW (Uncomplicated Firewall) configuration examples
```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

---

## 💾 Storage Management

### [create_new_partition](create_new_partition)
Guide for creating and formatting new disk partitions
```bash
fdisk /dev/sdX
mkfs.ext4 /dev/sdX1
```

### [howto_calculate_sectors](howto_calculate_sectors)
Calculate disk sectors for partitioning
- Useful for precise partition alignment
- SSD optimization

### [find_mounted_devices](find_mounted_devices)
List all mounted filesystems and devices
```bash
mount | column -t
lsblk -f
```

### [find-a-file](find-a-file)
Advanced file search examples
```bash
find / -name "filename"
find /path -type f -mtime -7  # Files modified in last 7 days
```

---

## 👤 User Management

### [usermod to add to groups](usermod%20to%20add%20to%20groups)
Add users to groups for permissions
```bash
usermod -aG docker username
usermod -aG sudo username
```

---

## 🔧 System Utilities

### [laptop_lidswitch_ignore](laptop_lidswitch_ignore)
Configure system to ignore laptop lid close
- Useful for servers built from laptops
- Prevent sleep when lid is closed

### [ubuntu-server-iso](ubuntu-server-iso)
Ubuntu Server installation notes and tips

---

## 🔑 Certificates

### [wildcard-cert-key-gen](wildcard-cert-key-gen)
Generate wildcard SSL certificates
- For multiple subdomains
- Let's Encrypt or self-signed options

---

## 📜 Git Commands

### [git-commands.txt](git-commands.txt)
Comprehensive Git command reference
- Initialize repository
- Clone, add, commit, push
- Branch management
- Remote configuration
- Common workflows

Quick reference:
```bash
git init
git clone <url>
git add .
git commit -m "message"
git push origin main
git pull
git branch
git checkout -b new-branch
```

---

## 🤖 Scripts Directory

Automation scripts for common tasks. See [scripts/README.md](scripts/README.md) for details.

### Backup and Restore
- **[backup.sh](scripts/backup.sh)** - Automated backup script
- **[restore_from_backup.sh](scripts/restore_from_backup.sh)** - Restore from backup

### Installation Scripts
- **[new-ubuntu-install.sh](scripts/new-ubuntu-install.sh)** - New Ubuntu system setup
- **[portainer-install.sh](scripts/portainer-install.sh)** - Install Portainer
- **[npm.sh](scripts/npm.sh)** - Install Nginx Proxy Manager

### Git Automation
- **[gitrepo-setup.sh](scripts/gitrepo-setup.sh)** - Initialize new git repository
- **[github-repo-update.sh](scripts/github-repo-update.sh)** - Update all repos
- **[gitcloneall.sh](scripts/gitcloneall.sh)** - Clone multiple repositories

### Security
- **[clam-rk-update-scan.sh](scripts/clam-rk-update-scan.sh)** - Update and run security scans
- **[login-checkup.sh](scripts/login-checkup.sh)** - Check for suspicious login activity

### Utilities
- **[hash.py](scripts/hash.py)** - File hashing utility
- **[cronjob script](scripts/cronjob%20script)** - Cron job examples
- **[Create create-desktop-icon.txt](scripts/Create%20create-desktop-icon.txt)** - Create desktop shortcuts

---

## 💡 Tips for Usage

### Before Running Scripts
1. ✅ Read the script to understand what it does
2. ✅ Check file permissions: `ls -la script.sh`
3. ✅ Make executable: `chmod +x script.sh`
4. ✅ Test in safe environment first
5. ✅ Backup important data

### Command History
Save useful commands to your history:
```bash
# Search command history
Ctrl + R

# Save command to file
history | grep "useful command" >> my-commands.txt
```

### Creating Your Own Commands
```bash
# Add to ~/.bashrc or ~/.bash_aliases
alias update='sudo apt update && sudo apt upgrade -y'
alias gs='git status'
alias ll='ls -lah'

# Reload
source ~/.bashrc
```

---

## 🔗 See Also
- [Proxmox Configuration](../proxmox/)
- [Security Tools](../anti-virus/)
- [Ansible Playbooks](../ansible/)
- [Docker Configurations](../portainer/)

---

## 📚 Additional Resources
- [Quick Start Guide](../docs/QUICK_START.md)
- [Best Practices](../docs/BEST_PRACTICES.md)
- [Troubleshooting](../docs/TROUBLESHOOTING.md)

---

[← Back to Main](../README.md)
