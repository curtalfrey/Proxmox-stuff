# Best Practices for Proxmox VE

A comprehensive guide to running Proxmox VE efficiently, securely, and reliably.

---

## Table of Contents
- [System Configuration](#system-configuration)
- [Storage Management](#storage-management)
- [Network Configuration](#network-configuration)
- [Security](#security)
- [Backup Strategy](#backup-strategy)
- [VM and Container Management](#vm-and-container-management)
- [Performance Optimization](#performance-optimization)
- [Monitoring and Maintenance](#monitoring-and-maintenance)

---

## System Configuration

### Updates and Patches
```bash
# Regular updates (weekly recommended)
apt update
apt full-upgrade -y

# Check for Proxmox-specific updates
pveversion -v

# Enable automatic security updates
apt install unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
```

### Repository Configuration
- ✅ **DO**: Use no-subscription repository for testing/homelab
- ✅ **DO**: Use enterprise repository for production (requires subscription)
- ❌ **DON'T**: Mix different repository versions
- ❌ **DON'T**: Use test repository in production

### System Resources
- **CPU**: Enable all virtualization features in BIOS (VT-x/AMD-V, VT-d/AMD-Vi)
- **RAM**: Reserve at least 2GB for Proxmox host
- **Swap**: Configure appropriate swap space (typically equal to RAM, or 4-8GB minimum)

---

## Storage Management

### Storage Types

#### Local Storage
- **Use for**: Proxmox installation, ISO images, container templates
- **Don't use for**: VM disk images in production (no redundancy)

#### ZFS
```bash
# Recommended for data integrity and performance
# Use RAID-Z1 (similar to RAID5) for 3+ drives
# Use RAID-Z2 (similar to RAID6) for 5+ drives
# Use mirrors for best performance with 2 drives
```

**Best practices:**
- Use SSD for ZFS L2ARC cache
- Use NVMe for ZFS SLOG (write cache)
- Set `atime=off` to reduce writes
- Regular scrubbing: `zpool scrub <pool-name>`

#### Shared Storage (for clusters)
- **NFS**: Easy setup, good for most use cases
- **Ceph**: Distributed storage, complex but powerful
- **iSCSI**: Block-level, good performance

### Disk Management
```bash
# Monitor disk health
smartctl -a /dev/sda

# Check disk usage
df -h

# Monitor I/O
iotop
```

**Best practices:**
- ✅ Use separate disks for OS and VM storage
- ✅ Enable SMART monitoring
- ✅ Use SSDs for VM storage when possible
- ✅ Regular backups (redundancy ≠ backup)

---

## Network Configuration

### Bridges
```bash
# Default bridge (vmbr0) is fine for most setups
# Create additional bridges for network isolation:

# Edit /etc/network/interfaces
auto vmbr1
iface vmbr1 inet static
    address 192.168.100.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
```

### VLANs
```bash
# Enable VLAN-aware on bridge
# Edit /etc/network/interfaces
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
    bridge-ports enp0s31f6
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 2-4094
```

### Firewall
- ✅ Enable Proxmox built-in firewall
- ✅ Configure rules at datacenter, node, and VM levels
- ✅ Use security groups for common rule sets
- ❌ Don't rely solely on host firewall

See: [UFW Firewall Tips](../helpful_commands/UFW-firewall-tips)

---

## Security

### SSH Hardening
```bash
# Disable root login
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Enable key-based authentication
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Disable password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH
systemctl restart sshd
```

See: [SSH Hardening Guide](../proxmox/ssh-harden-vm-in-proxmox)

### User Management
```bash
# Create non-root user
pveum user add user@pam
pveum passwd user@pam

# Assign roles
pveum acl modify / -user user@pam -role PVEAdmin
```

**Principle of least privilege:**
- ✅ Create separate users for different administrators
- ✅ Use role-based access control
- ❌ Don't share root password
- ❌ Don't use root for daily operations

### Anti-Virus and Rootkit Detection
```bash
# Install security tools
apt install clamav clamav-daemon rkhunter

# Update definitions
freshclam
rkhunter --update

# Run scans
clamscan -r /home
rkhunter --check
```

See: [Anti-Virus Setup](../anti-virus/)

### Two-Factor Authentication
```bash
# Install authenticator
apt install libpam-google-authenticator

# Setup for user
google-authenticator

# Enable in Proxmox
# GUI: Datacenter -> Permissions -> Two Factor
```

---

## Backup Strategy

### The 3-2-1 Rule
- **3** copies of data
- **2** different storage types
- **1** off-site backup

### Proxmox Built-in Backup
```bash
# Via GUI: Datacenter -> Backup
# Or via CLI:
vzdump 100 --mode snapshot --storage local --compress zstd

# Automated with cron:
# Weekly full backups, daily incrementals
```

**Best practices:**
- ✅ Schedule backups during low-usage hours
- ✅ Test restore procedures regularly
- ✅ Store backups on separate storage
- ✅ Keep multiple generations (retention policy)
- ✅ Verify backup integrity

### External Backup Solutions
- **Duplicati**: Encrypted cloud backups - [Setup Guide](../Duplicati/)
- **Proxmox Backup Server**: Official solution with deduplication
- **rsync**: Simple file-level backups

---

## VM and Container Management

### Choosing Between VMs and Containers

**Use VMs for:**
- Different kernel/OS than host
- Running Windows
- Full isolation required
- Untrusted workloads

**Use Containers for:**
- Linux workloads
- Resource efficiency
- Fast provisioning
- Microservices

### Resource Allocation

#### CPU
```bash
# Don't overallocate CPUs
# Rule of thumb: Total vCPUs ≤ Physical cores × 2

# Use CPU limit for containers
lxc.cgroup2.cpu.max: 200000 1000000  # 20% CPU limit
```

#### Memory
```bash
# Always set memory limits
# Leave headroom for host (2GB minimum)

# For VMs: Use ballooning for dynamic allocation
# For Containers: Set appropriate limits
```

#### Disk
```bash
# Use thin provisioning for flexibility
# Monitor actual usage vs allocated

# For containers:
pct resize 100 rootfs +5G  # Increase container disk
```

### Templates
```bash
# Create VM template
qm template 9000

# Create container template
# Download from Proxmox template repository

# Clone from template
qm clone 9000 101 --name new-vm
pct clone 100 101 --hostname new-ct
```

---

## Performance Optimization

### CPU
```bash
# Enable CPU hotplug for VMs
qm set 100 --hotplug cpu

# Use host CPU type for best performance
# (reduces migration compatibility)

# Pin CPUs for critical VMs
qm set 100 --cpuunits 2048
```

### Disk I/O
```bash
# Use VirtIO drivers (paravirtualization)
# Enable DISCARD/TRIM for SSDs
# Use cache=writeback for better performance (with UPS)
# Use cache=none or writethrough for data safety

# For VMs:
qm set 100 --scsi0 local-lvm:vm-100-disk-0,cache=writeback,discard=on

# Enable IO thread
qm set 100 --scsihw virtio-scsi-single --iothread 1
```

### Network
```bash
# Use VirtIO network adapter
# Enable multiqueue for network

# For VMs with high network load:
qm set 100 --net0 virtio,bridge=vmbr0,queues=4
```

### Memory
```bash
# Enable ballooning for dynamic memory
qm set 100 --balloon 2048

# Use huge pages for memory-intensive VMs
# Add to VM config:
hugepages: 1024
```

---

## Monitoring and Maintenance

### System Monitoring
```bash
# Check system status
pvesh get /cluster/resources

# Monitor services
systemctl status pve-cluster
systemctl status pvedaemon
systemctl status pveproxy

# View logs
journalctl -xe
tail -f /var/log/syslog
```

### Regular Maintenance Tasks

#### Daily
- Check for alerts in web interface
- Monitor resource usage
- Review backup completion

#### Weekly
- Apply security updates
- Review logs for errors
- Check disk space usage

#### Monthly
- Full system update
- Review and rotate logs
- Test backup restoration
- Review user access and permissions
- Check for firmware updates

#### Quarterly
- Audit security settings
- Review and update documentation
- Disaster recovery plan test
- Performance baseline review

### Health Checks
```bash
# Check cluster health (if clustered)
pvecm status

# Check storage health
pvesm status

# Check for updates
pveupdate

# System resource usage
htop
iotop
```

### Log Management
```bash
# Rotate logs to prevent disk full
logrotate /etc/logrotate.conf

# Archive old logs
journalctl --vacuum-time=30d
```

---

## Cluster Best Practices

### Minimum Requirements
- 3 nodes (for quorum)
- Reliable network connection between nodes
- Synchronized time (NTP)
- Shared storage for live migration

### Configuration
```bash
# Proper hostname resolution
# Edit /etc/hosts on all nodes

# Use dedicated network for cluster communication
# Separate from VM traffic

# Enable HA (High Availability) for critical VMs
```

### Quorum
- Always maintain odd number of nodes (3, 5, 7)
- Use QDevice for even-numbered clusters
- Monitor quorum status: `pvecm status`

---

## Common Mistakes to Avoid

### ❌ Don't Do This
1. **Running Proxmox in a VM** (nested virtualization issues)
2. **Using consumer-grade hardware for production** (reliability issues)
3. **Ignoring backups** ("RAID is not a backup")
4. **Overcommitting resources** (leads to performance issues)
5. **Mixing production and test on same cluster**
6. **Using GUI only** (learn CLI for troubleshooting)
7. **Ignoring security updates**
8. **Forgetting to test restores**
9. **Poor network planning** (causing bottlenecks)
10. **Not reading logs** (missing early warning signs)

### ✅ Do This Instead
1. Run Proxmox on bare metal
2. Use server-grade hardware with ECC RAM
3. Implement 3-2-1 backup strategy
4. Monitor and plan capacity
5. Use separate test environment
6. Learn both GUI and CLI
7. Enable automatic security updates
8. Regular restore testing
9. Plan network topology carefully
10. Regular log review and monitoring

---

## Resources

### Official Documentation
- [Proxmox VE Wiki](https://pve.proxmox.com/wiki/Main_Page)
- [Proxmox VE Administration Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html)

### Community
- [Proxmox Forum](https://forum.proxmox.com/)
- [Reddit r/Proxmox](https://www.reddit.com/r/Proxmox/)

### Related Guides
- [Quick Start Guide](QUICK_START.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

---

[← Back to Main README](../README.md)
