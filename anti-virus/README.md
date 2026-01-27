# Anti-Virus and Security Scanning

Security tools for virus scanning and rootkit detection on Linux systems.

---

## Contents

### Installation
**[1_clamav_rkhunter_install](1_clamav_rkhunter_install)** - Install ClamAV and RKhunter
- ClamAV: Open-source antivirus scanner
- RKhunter: Rootkit detection tool

### Scanning Scripts
**[2_clam-rk-update-scan.sh](2_clam-rk-update-scan.sh)** - Update definitions and run scans
- Updates virus definitions
- Updates rootkit database
- Runs comprehensive system scans

**[3_security_scan_results.sh](3_security_scan_results.sh)** - View scan results
- Parse and display scan findings
- Generate security reports

---

## Quick Start

### Installation
```bash
# Run the installation script
cd /path/to/Proxmox-stuff/anti-virus
./1_clamav_rkhunter_install

# Or install manually
apt update
apt install clamav clamav-daemon rkhunter -y
```

### Initial Setup
```bash
# Update virus definitions
freshclam

# Update RKhunter database
rkhunter --update
rkhunter --propupd
```

### Run Scans
```bash
# Use automated script
./2_clam-rk-update-scan.sh

# Or run manually:
# ClamAV scan
clamscan -r /home --log=/var/log/clamav/scan.log

# RKhunter check
rkhunter --check --skip-keypress --report-warnings-only
```

---

## About the Tools

### ClamAV
**What it does:**
- Detects viruses, trojans, malware
- Scans files and directories
- Can scan emails and web traffic
- Regular definition updates

**Best for:**
- File servers
- Email servers
- Web servers
- Workstations with Windows files

### RKhunter (Rootkit Hunter)
**What it does:**
- Detects rootkits
- Checks for backdoors
- Validates system binaries
- Monitors file integrity
- Checks for suspicious processes

**Best for:**
- Production servers
- Systems with SSH access
- Detecting compromised systems
- System integrity monitoring

---

## Usage Examples

### ClamAV Commands

#### Basic Scan
```bash
# Scan current directory
clamscan -r .

# Scan with verbose output
clamscan -r -v /home

# Scan and remove infected files (use with caution!)
clamscan -r --remove /path/to/scan
```

#### Scheduled Scans
```bash
# Add to crontab for daily scans at 2 AM
crontab -e
0 2 * * * /usr/bin/clamscan -r /home --log=/var/log/clamav/daily-scan.log

# Weekly full system scan on Sunday at 3 AM
0 3 * * 0 /usr/bin/clamscan -r / --exclude-dir=/proc --exclude-dir=/sys --log=/var/log/clamav/weekly-scan.log
```

#### Check Logs
```bash
# View ClamAV logs
tail -f /var/log/clamav/clamav.log

# View scan results
cat /var/log/clamav/scan.log | grep FOUND
```

### RKhunter Commands

#### Basic Check
```bash
# Full system check
rkhunter --check

# Skip prompts (for automated runs)
rkhunter --check --skip-keypress

# Show only warnings
rkhunter --check --report-warnings-only
```

#### Update and Maintain
```bash
# Update rootkit definitions
rkhunter --update

# Update file properties database (after system updates)
rkhunter --propupd

# Check version
rkhunter --version
```

#### Configuration
```bash
# Edit configuration
nano /etc/rkhunter.conf

# Important settings:
# MAIL-ON-WARNING=you@email.com  # Email on warnings
# UPDATE_MIRRORS=1                # Auto-update mirrors
# MIRRORS_MODE=0                  # Mirror mode
```

---

## Automation

### Cron Job Setup
```bash
# Create cron job for automated scanning
crontab -e

# Add these lines:
# Update ClamAV definitions daily at 1 AM
0 1 * * * /usr/bin/freshclam --quiet

# Run security scans daily at 2 AM
0 2 * * * /path/to/2_clam-rk-update-scan.sh

# Update RKhunter weekly on Monday at midnight
0 0 * * 1 /usr/bin/rkhunter --update --quiet
```

### Automated Script
Use the provided script for complete automation:
```bash
# Make executable
chmod +x 2_clam-rk-update-scan.sh

# Run it
./2_clam-rk-update-scan.sh

# This will:
# 1. Update virus definitions
# 2. Update rootkit database
# 3. Run ClamAV scan
# 4. Run RKhunter check
# 5. Save results to log files
```

---

## Configuration Tips

### ClamAV Configuration
```bash
# Edit daemon config
nano /etc/clamav/clamd.conf

# Key settings:
# LogFile /var/log/clamav/clamav.log
# MaxFileSize 100M
# MaxScanSize 500M

# Restart service after changes
systemctl restart clamav-daemon
```

### RKhunter Configuration
```bash
# Edit main config
nano /etc/rkhunter.conf

# Recommended settings:
MAIL-ON-WARNING=root@localhost
PKGMGR=DPKG                    # For Debian/Ubuntu
UPDATE_MIRRORS=1
WEB_CMD="/usr/bin/wget"

# Whitelist known safe files
ALLOWHIDDENDIR=/dev/.udev
ALLOWHIDDENDIR=/dev/.static

# After changing config
rkhunter --propupd
```

---

## Interpreting Results

### ClamAV Results
```bash
# Clean scan result:
----------- SCAN SUMMARY -----------
Known viruses: 8654183
Engine version: 0.103.8
Scanned directories: 245
Scanned files: 3829
Infected files: 0
Data scanned: 1024.53 MB
Time: 45.321 sec (0 m 45 s)

# If infected files found:
/path/to/file: Win.Trojan.Agent FOUND
# Take action: quarantine, delete, or investigate
```

### RKhunter Results
```bash
# Clean result:
System checks summary
=====================
File properties checks...
  Files checked: 137
  Suspect files: 0

# If warnings found:
Warning: The file '/usr/bin/binary' has been modified
# Action needed: Verify if legitimate update or compromise
```

---

## Best Practices

### ✅ Do This
1. **Regular Updates**: Update definitions daily
2. **Scheduled Scans**: Run scans during low-usage hours
3. **Monitor Logs**: Review scan results regularly
4. **After Updates**: Run `rkhunter --propupd` after system updates
5. **Backup Logs**: Keep scan history for trend analysis
6. **Multiple Layers**: Use both tools for comprehensive coverage

### ⚠️ Cautions
1. **False Positives**: Verify before deleting files
2. **Performance**: Scans can be resource-intensive
3. **System Updates**: Update RKhunter database after system changes
4. **Scanning Root**: Be careful with automatic deletion
5. **Production Systems**: Schedule scans during maintenance windows

---

## Troubleshooting

### ClamAV Issues
```bash
# Service not starting
systemctl status clamav-daemon
journalctl -u clamav-daemon

# Can't update definitions
freshclam -d  # Debug mode

# Permission errors
chown -R clamav:clamav /var/lib/clamav
```

### RKhunter Issues
```bash
# Too many warnings after update
rkhunter --propupd

# Can't connect to update server
rkhunter --update --debug

# False positive for specific file
# Add to /etc/rkhunter.conf:
ALLOWHIDDENDIR=/path/to/directory
```

---

## See Also
- [Security Policy](../SECURITY.md)
- [Best Practices](../docs/BEST_PRACTICES.md)
- [SSH Hardening](../proxmox/ssh-harden-vm-in-proxmox)
- [Firewall Configuration](../helpful_commands/UFW-firewall-tips)

---

[← Back to Main](../README.md)
