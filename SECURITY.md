# Security Policy

## Supported Versions

This repository contains scripts and configurations for Proxmox VE and related tools. We recommend always using the latest version of Proxmox VE and keeping all systems up to date.

| Proxmox VE Version | Supported          |
| ------------------ | ------------------ |
| 8.x                | :white_check_mark: |
| 7.x                | :white_check_mark: |
| 6.x                | :warning: Limited  |
| < 6.0              | :x:                |

---

## Security Considerations

### Before Using Scripts

⚠️ **Important**: Always review scripts before running them on your system.

1. **Read the entire script** to understand what it does
2. **Check for hardcoded credentials** and replace them with your own
3. **Test in a non-production environment** first
4. **Backup your system** before making changes
5. **Verify the source** and ensure scripts are from trusted contributors

### Common Security Practices

#### Credentials Management
```bash
# ❌ DON'T hardcode passwords in scripts
PASSWORD="mypassword123"

# ✅ DO use environment variables or secure prompts
read -sp "Enter password: " PASSWORD
# or
PASSWORD="${DB_PASSWORD}"
```

#### File Permissions
```bash
# ✅ Ensure scripts containing sensitive data have proper permissions
chmod 600 script-with-credentials.sh

# ✅ Limit access to configuration files
chmod 600 config.yml
chown root:root config.yml
```

#### SSH Security
- Use key-based authentication instead of passwords
- Disable root login over SSH
- Use strong passphrases for SSH keys
- Implement fail2ban or similar tools

See: [SSH Hardening Guide](proxmox/ssh-harden-vm-in-proxmox)

#### Network Security
- Configure firewall rules (UFW/iptables)
- Use private networks for internal communication
- Implement VLANs for network segmentation
- Enable Proxmox built-in firewall

See: [UFW Firewall Tips](helpful_commands/UFW-firewall-tips)

---

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please report it responsibly:

### How to Report

1. **DO NOT** create a public GitHub issue for security vulnerabilities
2. **DO** email the maintainer at: [See README for contact info](README.md)
3. **Include** the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 1 week
- **Fix Timeline**: Depends on severity
  - **Critical**: Within 7 days
  - **High**: Within 30 days
  - **Medium**: Within 90 days
  - **Low**: Best effort basis

### After Reporting

- We will work with you to understand and verify the issue
- We will develop and test a fix
- We will release a patch and security advisory
- We will credit you (if desired) in the security advisory

---

## Security Best Practices

### For System Administrators

#### Regular Updates
```bash
# Keep Proxmox updated
apt update
apt full-upgrade

# Enable automatic security updates
apt install unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
```

#### Security Scanning
```bash
# Install security tools
apt install clamav clamav-daemon rkhunter

# Regular scans
freshclam
clamscan -r /home
rkhunter --check
```

See: [Anti-Virus Setup](anti-virus/)

#### Backup Strategy
```bash
# Implement 3-2-1 backup rule
# - 3 copies of data
# - 2 different storage types
# - 1 off-site backup

# Regular Proxmox backups
vzdump --all --mode snapshot --compress zstd
```

#### Access Control
```bash
# Use principle of least privilege
# Create non-root users with specific roles
pveum user add user@pam
pveum acl modify / -user user@pam -role PVEAdmin

# Implement two-factor authentication
apt install libpam-google-authenticator
```

### For Developers/Contributors

#### Code Review
- All scripts should be reviewed before merging
- Check for security issues:
  - Hardcoded credentials
  - Command injection vulnerabilities
  - Insufficient input validation
  - Insecure file operations

#### Sensitive Data
```bash
# ❌ NEVER commit:
- Passwords or API keys
- Private SSH keys
- SSL certificates (private keys)
- Personal/production IP addresses
- Database credentials

# ✅ Use instead:
- Environment variables
- Configuration templates with placeholders
- References to external credential stores
- Example configurations with dummy data
```

#### Input Validation
```bash
# ✅ Always validate user input
validate_input() {
    local input="$1"
    if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: Invalid input"
        exit 1
    fi
}

# ✅ Sanitize file paths
sanitize_path() {
    realpath --relative-to="$BASE_DIR" "$1"
}

# ✅ Use quotes to prevent injection
file="user_provided_name.txt"
rm "$file"  # Safe
rm $file    # Unsafe - subject to word splitting
```

---

## Known Security Considerations

### Scripts in This Repository

#### Root/Sudo Access
Many scripts require root or sudo access. Always:
- Review what the script does with elevated privileges
- Run in a test environment first
- Backup before making system changes

#### Network Exposure
Some configurations expose services to the network:
- Review port mappings in docker-compose files
- Configure firewall rules appropriately
- Use strong authentication
- Keep services updated

#### Proxmox Web Interface
- Default port 8006 uses self-signed certificate
- Change default passwords immediately
- Enable two-factor authentication
- Restrict access by IP if possible

#### Container Security
```yaml
# Docker security best practices
services:
  app:
    # ✅ Use specific versions, not :latest
    image: nginx:1.21.6
    
    # ✅ Run as non-root user
    user: "1000:1000"
    
    # ✅ Set read-only root filesystem
    read_only: true
    
    # ✅ Limit capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    
    # ✅ Use secrets for sensitive data
    secrets:
      - db_password
```

---

## Security Checklist

### For New Scripts
- [ ] No hardcoded credentials
- [ ] Input validation implemented
- [ ] Proper error handling
- [ ] Secure file permissions set
- [ ] Logging of security events
- [ ] Clear documentation of requirements
- [ ] Tested in isolated environment

### For Configurations
- [ ] Default passwords changed/removed
- [ ] Unnecessary ports closed
- [ ] SSL/TLS enabled where applicable
- [ ] Authentication configured
- [ ] Access control implemented
- [ ] Secrets using environment variables
- [ ] Documentation includes security notes

### For System Setup
- [ ] System fully updated
- [ ] Firewall configured
- [ ] SSH hardened
- [ ] Backups configured
- [ ] Monitoring enabled
- [ ] Security scanning installed
- [ ] Two-factor authentication enabled

---

## Security Resources

### Proxmox Security
- [Proxmox Security Guide](https://pve.proxmox.com/wiki/Security)
- [Proxmox Firewall](https://pve.proxmox.com/wiki/Firewall)

### General Linux Security
- [Linux Security Modules](https://www.kernel.org/doc/html/latest/admin-guide/LSM/index.html)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

### Docker Security
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

---

## Disclaimer

⚠️ **Important Disclaimer**:

- Scripts and configurations are provided "as-is" without warranty
- Always test in non-production environments first
- Review and understand code before execution
- Maintain backups of your systems
- Security is your responsibility
- Keep systems and software updated

---

## License

This security policy is part of the Proxmox-stuff repository and is subject to the same MIT License.

---

**Last Updated**: 2026-01-27

For questions or concerns about security, please refer to the reporting guidelines above.
