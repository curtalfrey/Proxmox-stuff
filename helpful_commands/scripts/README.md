# Automation Scripts

Collection of shell scripts for automating common system administration tasks.

---

## ⚠️ Important Security Notice

Before running any script:
1. **Read the script** to understand what it does
2. **Test in a safe environment** first
3. **Backup your data** before making system changes
4. **Check for hardcoded values** that need customization
5. **Ensure proper permissions**: `chmod +x script.sh`

---

## Contents

### 📦 Backup & Restore
- **[backup.sh](backup.sh)** - Automated backup script
  - Backup important directories
  - Compress and archive
  - Timestamped backups
  
- **[restore_from_backup.sh](restore_from_backup.sh)** - Restore from backup archives
  - Usage: `restore_from_backup.sh <backup.tar.gz.enc> [restore_dir]`
  - Extract backup files
  - Restore to original locations
  - Verify restoration

### 🔐 Security & Monitoring
- **[clam-rk-update-scan.sh](clam-rk-update-scan.sh)** - Security scanning automation
  - Update ClamAV virus definitions
  - Update RKhunter database
  - Run full system scans
  - Generate security reports

- **[login-checkup.sh](login-checkup.sh)** - Monitor login activity
  - Check for suspicious login attempts
  - Review authentication logs
  - Detect brute force attempts
  - Generate security alerts

### 🔧 System Setup
- **[new-ubuntu-install.sh](new-ubuntu-install.sh)** - New system setup automation
  - Install essential packages
  - Configure system settings
  - Setup development tools
  - Apply security hardening

### 🐳 Container Management
- **[portainer-install.sh](portainer-install.sh)** - Install Portainer
  - Deploy Portainer container
  - Configure persistent storage
  - Setup web interface access

- **[npm.sh](npm.sh)** - Install Nginx Proxy Manager
  - Deploy NPM container
  - Configure networks
  - Setup SSL certificates

### 📂 Git Automation
- **[gitrepo-setup.sh](gitrepo-setup.sh)** - Initialize new Git repository
  - Create git repository
  - Configure remote
  - Initial commit
  - Setup .gitignore

- **[github-repo-update.sh](github-repo-update.sh)** - Update Git repositories
  - Pull latest changes
  - Check for conflicts
  - Update multiple repositories

- **[gitcloneall.sh](gitcloneall.sh)** - Clone multiple repositories
  - Usage: `gitcloneall.sh <github-username>` (pages through all public repos)
  - Clone from list
  - Organize by project
  - Batch operations

### 🛠️ Utilities
- **[hash.py](hash.py)** - File hashing utility
  - Generate file hashes (MD5, SHA256)
  - Verify file integrity
  - Compare checksums

- **[cronjob script](cronjob%20script)** - Cron job examples
  - Scheduling syntax
  - Common automation tasks
  - Best practices

- **[Create create-desktop-icon.txt](Create%20create-desktop-icon.txt)** - Desktop shortcut creation
  - Linux desktop entry format
  - Icon configuration
  - Application launchers

- **[monitoring-stack](monitoring-stack)** - Monitoring tools setup
  - Deploy monitoring solutions
  - Configure dashboards
  - Setup alerts

---

## Usage Examples

### Running Scripts

#### Make Executable
```bash
chmod +x script.sh
```

#### Run Script
```bash
# Direct execution
./script.sh

# With sudo (if needed)
sudo ./script.sh

# With arguments
./script.sh arg1 arg2

# In background
./script.sh &

# With output logging
./script.sh 2>&1 | tee script.log
```

### Scheduling with Cron

```bash
# Edit crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /path/to/backup.sh

# Weekly security scan on Sunday at 3 AM
0 3 * * 0 /path/to/clam-rk-update-scan.sh

# Hourly git update
0 * * * * /path/to/github-repo-update.sh

# Every 5 minutes (monitoring)
*/5 * * * * /path/to/monitoring-script.sh
```

---

## Customization Tips

### Variables
Most scripts have variables at the top:
```bash
# Edit these for your environment
BACKUP_DIR="/backup"
LOG_FILE="/var/log/script.log"
RETENTION_DAYS=7
```

### Paths
Update paths to match your system:
```bash
# Source directories
SOURCE_DIRS="/home /var/www /etc"

# Destination
DEST="/mnt/backups"
```

### Notifications
Add email notifications:
```bash
# At end of script
mail -s "Script Completed" admin@example.com < /tmp/report.txt
```

---

## Best Practices

### ✅ Do This
1. **Test in dev/staging** before production
2. **Read and understand** scripts before running
3. **Check permissions** on sensitive files
4. **Log script output** for debugging
5. **Use absolute paths** in scripts
6. **Set error handling** (`set -e`, error checks)
7. **Add comments** for complex operations
8. **Version control** your scripts

### Script Template
```bash
#!/bin/bash
# Script: script-name.sh
# Description: What this script does
# Author: Your Name
# Date: 2024-01-27

# Exit on error
set -e

# Configuration
VARIABLE="value"
LOG_FILE="/var/log/script.log"

# Functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# Main script
log "Starting script..."

# Your code here
command || error_exit "Command failed"

log "Script completed successfully"
```

---

## Troubleshooting

### Permission Denied
```bash
# Make executable
chmod +x script.sh

# Check ownership
ls -l script.sh

# Fix ownership if needed
chown user:user script.sh
```

### Command Not Found
```bash
# Use absolute paths
which command
# Then use: /usr/bin/command

# Or add to PATH
export PATH=$PATH:/usr/local/bin
```

### Script Fails Silently
```bash
# Run with debugging
bash -x script.sh

# Add to script for debug mode
set -x  # Enable debug
# commands
set +x  # Disable debug

# Check exit code
echo $?  # 0 = success, non-zero = error
```

---

## Security Considerations

### ⚠️ Important
- **Never hardcode passwords** in scripts
- **Use environment variables** for credentials
- **Restrict file permissions** (600 or 700)
- **Validate user input** to prevent injection
- **Use secure deletion** for sensitive data
- **Log security events** appropriately

### Secure Script Permissions
```bash
# Owner only
chmod 700 script.sh

# Read-only for others
chmod 755 script.sh

# Sensitive scripts
chmod 600 script.sh
chown root:root script.sh
```

### Environment Variables
```bash
# Set before running
export DB_PASSWORD="secret"
./script.sh

# Or in script
DB_PASSWORD="${DB_PASSWORD:-}"
if [ -z "$DB_PASSWORD" ]; then
    echo "Error: DB_PASSWORD not set"
    exit 1
fi
```

---

## Adding New Scripts

### Contribution Guidelines
When adding new scripts:

1. **Include header** with description
2. **Add error handling**
3. **Use meaningful variable names**
4. **Add comments** for complex logic
5. **Make configurable** with variables
6. **Test thoroughly**
7. **Update this README**

### Script Checklist
- [ ] Shebang line (`#!/bin/bash`)
- [ ] Description header
- [ ] Error handling (`set -e` or checks)
- [ ] Configurable variables
- [ ] Help/usage function
- [ ] Logging capability
- [ ] Comments for clarity
- [ ] Tested and working

---

## See Also
- [Helpful Commands](../)
- [Ansible Automation](../../ansible/)
- [Best Practices](../../docs/BEST_PRACTICES.md)
- [Security Policy](../../SECURITY.md)

---

## Quick Reference

```bash
# Make executable
chmod +x script.sh

# Run script
./script.sh

# Run with sudo
sudo ./script.sh

# Schedule with cron
crontab -e

# Debug mode
bash -x script.sh

# Check syntax
bash -n script.sh
```

---

[← Back to Helpful Commands](../)
