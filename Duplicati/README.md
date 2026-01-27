# Duplicati Backup Solution

Docker Compose configuration for Duplicati - a free backup solution with encryption and cloud storage support.

---

## What is Duplicati?

Duplicati is a backup solution that features:
- **Encryption**: AES-256 encryption for all backups
- **Compression**: Reduce backup size
- **Incremental Backups**: Only backup changed files
- **Cloud Storage**: Support for AWS, Google Drive, Dropbox, etc.
- **Scheduling**: Automated backup schedules
- **Versioning**: Keep multiple versions of files
- **Web Interface**: Easy configuration and monitoring

---

## Contents

### [docker-compose.yml](docker-compose.yml)
Duplicati Docker deployment configuration

### [install](install)
Installation instructions and setup guide

---

## Quick Start

### Deploy with Docker Compose
```bash
cd /path/to/Proxmox-stuff/Duplicati

# Start Duplicati
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Access Web Interface
1. Open browser: `http://YOUR_SERVER_IP:8200`
2. Set password on first access (recommended)
3. Start configuring backups

---

## Configuration

### Basic Backup Setup

1. **Click "Add backup"**
2. **Name and encryption:**
   - Name: Descriptive name
   - Encryption: AES-256 (recommended)
   - Passphrase: Strong password (SAVE THIS!)

3. **Destination:**
   - Storage Type: Choose (Local, S3, Google Drive, etc.)
   - Path/Settings: Configure for chosen storage
   - Test connection

4. **Source data:**
   - Add folders to backup
   - Exclude patterns (e.g., `*.tmp`, `cache/`)

5. **Schedule:**
   - Choose frequency (daily, weekly, etc.)
   - Set time for backups

6. **Options:**
   - Retention policy
   - Compression level
   - Advanced settings

7. **Save and run**

---

## Storage Backends

### Local Storage
```
Type: Local folder or drive
Path: /backups
Good for: Initial backups, testing
```

### Amazon S3
```
Type: S3 Compatible
AWS Access Key ID: your-key
AWS Secret Access Key: your-secret
Bucket: your-bucket-name
Good for: Reliable, scalable cloud storage
```

### Google Drive
```
Type: Google Drive
Authenticate: Via OAuth
Folder: /Backups
Good for: Free storage with Google account
```

### SFTP
```
Type: SFTP (SSH)
Server: your-server.com
Port: 22
Username: backup-user
Path: /remote/backup/path
Good for: Your own servers
```

### Other Supported
- Dropbox
- Microsoft OneDrive
- Backblaze B2
- Azure Blob Storage
- OpenStack
- FTP
- WebDAV
- More...

---

## Backup Strategies

### 3-2-1 Rule
Implement proper backup strategy:
- **3** copies of data
- **2** different storage types
- **1** off-site backup

### Example Configuration

#### Daily Local Backup
```
Name: Daily-Local
Source: /home, /var/www
Destination: /backups/duplicati
Schedule: Daily at 2 AM
Retention: Keep 7 days
```

#### Weekly Cloud Backup
```
Name: Weekly-Cloud
Source: /home, /var/www
Destination: Google Drive
Schedule: Weekly on Sunday at 3 AM
Retention: Keep 4 weeks
```

#### Monthly Archive
```
Name: Monthly-Archive
Source: /home, /var/www
Destination: Amazon S3
Schedule: Monthly on 1st at 1 AM
Retention: Keep 12 months
```

---

## Important Settings

### Retention Policies
```
# Keep backups for specific time
Delete backups older than: 30 days

# Keep specific number of versions
Keep all backups: 7 versions

# Smart retention
Keep one backup per day for 7 days
Keep one backup per week for 4 weeks
Keep one backup per month for 12 months
```

### Excluded Patterns
```
*.tmp
*.temp
*.cache
*/cache/*
*/temp/*
*/.git/*
*/node_modules/*
*/__pycache__/*
```

### Advanced Options
```
# Compression
--compression-module=zip
--compression-level=6

# Block size (performance vs dedupe)
--blocksize=100KB

# Upload limits
--throttle-upload=1024KB
--throttle-download=1024KB

# Verification
--backup-test-samples=1
```

---

## Backup Best Practices

### ✅ Do This
1. **Test restores regularly** - Verify backups work
2. **Use strong encryption** - Protect your data
3. **Keep passphrase safe** - Store in password manager
4. **Monitor backup jobs** - Check for failures
5. **Use multiple destinations** - Follow 3-2-1 rule
6. **Exclude unnecessary data** - Save space and time
7. **Schedule during off-hours** - Minimize impact

### ⚠️ Important Notes
- **Save encryption passphrase** - Without it, backups are useless
- **Test restore process** - Know how to recover data
- **Monitor disk space** - Both local and remote
- **Keep Duplicati updated** - Bug fixes and features
- **Verify backup integrity** - Use built-in verification

---

## Restoring Files

### Via Web Interface
1. **Go to "Restore"**
2. **Select backup source**
3. **Choose restore point** (date/time)
4. **Browse and select files**
5. **Choose restore location**
6. **Restore**

### Command Line Restore
```bash
# List available backups
duplicati-cli list "file:///backup/path"

# Restore specific files
duplicati-cli restore "file:///backup/path" \
  --restore-path=/restore/location \
  "/path/to/file.txt"

# Restore to specific time
duplicati-cli restore "file:///backup/path" \
  --restore-path=/restore/location \
  --version=2024-01-27

# Restore everything
duplicati-cli restore "file:///backup/path" \
  --restore-path=/restore/location
```

---

## Monitoring and Maintenance

### Check Backup Status
- Dashboard shows recent backups
- Email notifications for failures
- Log files for troubleshooting

### Email Notifications
```
Settings → Default options
send-mail-to: your@email.com
send-mail-from: duplicati@yourserver.com
send-mail-subject: Duplicati backup report
send-mail-url: smtp://smtp.gmail.com:587
send-mail-username: your@gmail.com
send-mail-password: your-app-password
```

### Verify Backups
Run verification to check integrity:
```bash
# From web interface:
Backup → Options → Verify files

# Or schedule automatic verification
Advanced options → backup-test-samples
```

---

## Troubleshooting

### Backup Fails
```bash
# Check logs
docker-compose logs duplicati

# Check disk space
df -h

# Verify destination accessible
# Test connection in Duplicati UI

# Check permissions
ls -la /backup/path
```

### Slow Backups
```
# Adjust block size
--blocksize=100KB  # Larger = faster, less dedup

# Limit resources
--thread-priority=lowest
--throttle-upload=1024KB

# Compress less
--compression-level=1
```

### Cannot Access Web Interface
```bash
# Check container status
docker-compose ps

# Check port
netstat -tlnp | grep 8200

# Restart container
docker-compose restart

# Check firewall
ufw allow 8200/tcp
```

### Lost Encryption Passphrase
**Unfortunately, if you lose the encryption passphrase, your backups are unrecoverable.** This is by design for security.

**Prevention:**
- Store passphrase in password manager
- Keep physical backup in safe place
- Document and share with trusted person

---

## Security Considerations

### Encryption
- Always use AES-256 encryption
- Use strong, unique passphrase (20+ characters)
- Never store passphrase in backup

### Access Control
```bash
# Set password for web interface
# First access will prompt for password

# Restrict network access
# In docker-compose.yml:
ports:
  - "127.0.0.1:8200:8200"  # Local only

# Use SSH tunnel
ssh -L 8200:localhost:8200 user@server
```

### Cloud Storage
- Use application-specific passwords
- Enable 2FA on cloud accounts
- Review access logs regularly
- Use dedicated backup accounts

---

## Updating Duplicati

```bash
# Pull latest image
docker-compose pull

# Recreate container
docker-compose up -d

# Verify update
docker-compose logs
```

---

## Backup Scripts Integration

### Automated Backup Script
```bash
#!/bin/bash
# Pre-backup script: Stop services

systemctl stop myapp

# Run backup (Duplicati handles this)

# Post-backup script: Start services
systemctl start myapp
```

Configure in Duplicati:
```
Advanced options:
run-script-before: /scripts/pre-backup.sh
run-script-after: /scripts/post-backup.sh
```

---

## See Also
- [Backup Scripts](../helpful_commands/scripts/)
- [Security Best Practices](../docs/BEST_PRACTICES.md)
- [Proxmox Backup](../proxmox/)

### Official Resources
- [Duplicati Documentation](https://duplicati.readthedocs.io/)
- [Duplicati Forum](https://forum.duplicati.com/)
- [Duplicati GitHub](https://github.com/duplicati/duplicati)

---

## Common Backup Sources

### System Files
```
/etc/
/home/
/var/www/
/root/
```

### Databases
```bash
# MySQL/MariaDB
mysqldump -u root -p database > /backup/db.sql

# PostgreSQL  
pg_dump database > /backup/db.sql

# Then backup the SQL files
```

### Docker Volumes
```bash
# Backup Docker volumes
docker run --rm \
  -v volume_name:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/volume.tar.gz -C /data .
```

### Proxmox VMs
```bash
# Use vzdump for VM backups
vzdump 100 --storage local --mode snapshot
# Then backup /var/lib/vz/dump/
```

---

[← Back to Main](../README.md)
