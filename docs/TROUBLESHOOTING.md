# Troubleshooting Guide

Common issues and their solutions for Proxmox VE and related tools.

---

## Table of Contents
- [Installation Issues](#installation-issues)
- [Network Problems](#network-problems)
- [Storage Issues](#storage-issues)
- [VM and Container Issues](#vm-and-container-issues)
- [Performance Problems](#performance-problems)
- [Cluster Issues](#cluster-issues)
- [Web Interface Issues](#web-interface-issues)
- [Backup and Restore](#backup-and-restore)
- [Security and Access](#security-and-access)

---

## Installation Issues

### Cannot Boot from USB
**Symptoms**: USB not detected or boot fails

**Solutions**:
```bash
# 1. Verify USB was written correctly
# Re-create using Etcher or:
dd if=proxmox.iso of=/dev/sdX bs=1M status=progress

# 2. Check BIOS settings
# - Enable USB boot
# - Disable Secure Boot
# - Enable Legacy/CSM mode if needed

# 3. Try different USB port
# - Use USB 2.0 port instead of 3.0
# - Try rear ports instead of front panel
```

### Installation Hangs or Freezes
**Symptoms**: Installation stops at particular step

**Solutions**:
```bash
# 1. Check hardware compatibility
# - Verify CPU has virtualization support
# - Check RAM is properly seated
# - Test with minimal hardware (remove extra devices)

# 2. Boot in debug mode
# At boot menu, press 'e' and add:
debug

# 3. Check system logs
# Press Ctrl+Alt+F2 to access console
dmesg | tail -50
```

### Disk Not Detected During Installation
**Symptoms**: No disks shown in installer

**Solutions**:
```bash
# 1. Check BIOS/UEFI settings
# - Enable AHCI mode for SATA
# - Disable RAID mode if not needed

# 2. For NVMe drives
# Update BIOS to latest version

# 3. Check disk health
# Boot from live Linux USB and check:
lsblk
fdisk -l
```

---

## Network Problems

### Cannot Access Web Interface
**Symptoms**: Browser cannot connect to `https://IP:8006`

**Solutions**:
```bash
# 1. Verify network configuration
ip addr show
ip route show

# 2. Check if service is running
systemctl status pveproxy
systemctl status pvedaemon

# 3. Restart services
systemctl restart pveproxy
systemctl restart pvedaemon

# 4. Check firewall
ufw status
iptables -L -n

# 5. Check if listening on correct port
netstat -tlnp | grep 8006

# 6. Test from Proxmox host
curl -k https://localhost:8006
```

### Network Loops/Broadcast Storm
**Symptoms**: Network becomes slow or unresponsive

**Solutions**:
```bash
# 1. Disable STP temporarily
ip link set vmbr0 type bridge stp_state 0

# 2. Check bridge configuration
brctl show

# 3. Verify no duplicate MAC addresses
# In VM configs, ensure unique MAC addresses

# 4. Permanent fix in /etc/network/interfaces
bridge-stp off
bridge-fd 0
```

### VMs Have No Network Connectivity
**Symptoms**: VMs cannot access network or internet

**Solutions**:
```bash
# 1. Check bridge configuration on host
brctl show
ip link show vmbr0

# 2. Verify VM network settings
# In VM -> Hardware -> Network Device
# Should be connected to correct bridge (vmbr0)

# 3. Check inside VM
# For Linux VMs:
ip addr show
ip route show
ping 8.8.8.8

# 4. Verify host can route
sysctl net.ipv4.ip_forward  # Should be 1
echo 1 > /proc/sys/net/ipv4/ip_forward

# 5. Check firewall rules
iptables -L -n -v
```

### DNS Not Working
**Symptoms**: Cannot resolve hostnames

**Solutions**:
```bash
# 1. Check DNS settings
cat /etc/resolv.conf

# 2. Test DNS resolution
nslookup google.com
dig google.com

# 3. Set DNS servers
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# 4. For permanent fix, edit network config
# /etc/network/interfaces
# Add: dns-nameservers 8.8.8.8 8.8.4.4

# 5. Restart networking
systemctl restart networking
```

---

## Storage Issues

### Storage Full
**Symptoms**: "No space left on device" errors

**Solutions**:
```bash
# 1. Check disk usage
df -h
du -sh /* | sort -h

# 2. Find large files
find / -type f -size +1G -exec ls -lh {} \;

# 3. Clean up
# Remove old backups
rm /var/lib/vz/dump/*

# Clean package cache
apt clean
apt autoclean

# Clean logs
journalctl --vacuum-time=7d

# Remove unused container templates
pveam remove <template>

# 4. Extend logical volume (if using LVM)
lvextend -L +10G /dev/pve/root
resize2fs /dev/pve/root
```

### ZFS Pool Degraded
**Symptoms**: "DEGRADED" status in zpool status

**Solutions**:
```bash
# 1. Check pool status
zpool status -v

# 2. Identify failed disk
# Look for UNAVAIL or FAULTED drives

# 3. Replace disk
# After physically replacing:
zpool replace poolname old-disk new-disk

# 4. Monitor resilver progress
zpool status

# 5. Scrub after resilver completes
zpool scrub poolname
```

### Slow Disk I/O
**Symptoms**: Poor VM performance, high I/O wait

**Solutions**:
```bash
# 1. Check I/O load
iotop -o

# 2. Monitor disk performance
iostat -x 5

# 3. Check SMART status
smartctl -a /dev/sda

# 4. Optimize VM disk settings
# Use VirtIO drivers
# Enable discard/TRIM
# Adjust cache settings

# 5. For ZFS
# Check ARC usage
arc_summary

# Adjust ARC size
echo 8589934592 > /sys/module/zfs/parameters/zfs_arc_max  # 8GB

# 6. Check for scrubbing
zpool status  # Should not run during heavy load
```

---

## VM and Container Issues

### VM Won't Start
**Symptoms**: Error when starting VM

**Solutions**:
```bash
# 1. Check error message in logs
journalctl -xe
tail -f /var/log/syslog

# 2. Check if VM is locked
qm unlock <vmid>

# 3. Check storage availability
pvesm status

# 4. Verify VM configuration
cat /etc/pve/qemu-server/<vmid>.conf

# 5. Check resource availability
# Ensure enough RAM, CPU, storage

# 6. Try starting in debug mode
qm start <vmid> --debug

# 7. Check for conflicting VMs
# Ensure no MAC or IP conflicts
```

### Container Won't Start
**Symptoms**: LXC container fails to start

**Solutions**:
```bash
# 1. Check container status
pct status <ctid>

# 2. View container config
pct config <ctid>

# 3. Check logs
journalctl -u pve-container@<ctid>

# 4. Try to start with verbose output
pct start <ctid> --debug

# 5. Check if storage is mounted
mount | grep lxc

# 6. Verify container filesystem
pct fsck <ctid>

# 7. Check for resource conflicts
# Ensure unique IPs, MACs, mount points
```

### Cannot Access VM Console
**Symptoms**: noVNC console blank or not working

**Solutions**:
```bash
# 1. Check VM is actually running
qm status <vmid>

# 2. Verify display settings in VM config
# VGA should be set (e.g., std, virtio, qxl)

# 3. Restart VM
qm reboot <vmid>

# 4. Access via SSH instead
ssh user@vm-ip

# 5. Check for console errors in browser
# Open browser dev tools (F12)

# 6. Try different browser or clear cache
```

### VM Performance is Slow
**Symptoms**: VM runs slower than expected

**Solutions**:
```bash
# 1. Install VirtIO drivers
# For Windows: Download virtio-win ISO

# 2. Check resource allocation
qm config <vmid>

# 3. Monitor resource usage
# In Proxmox GUI: VM -> Summary

# 4. Adjust CPU settings
qm set <vmid> --cores 4 --cpu host

# 5. Enable disk caching
qm set <vmid> --scsi0 local-lvm:vm-100-disk-0,cache=writeback

# 6. Enable IO threads
qm set <vmid> --scsihw virtio-scsi-single --iothread 1

# 7. Check host load
htop
iotop
```

---

## Performance Problems

### High CPU Usage on Host
**Symptoms**: Host CPU constantly high

**Solutions**:
```bash
# 1. Identify processes
top
htop

# 2. Check per-VM CPU usage
# In web interface: Summary view

# 3. Limit VM CPU usage
qm set <vmid> --cpulimit 2  # 2 cores max

# 4. Check for runaway processes
ps aux --sort=-%cpu | head

# 5. Review VM configurations
# Ensure not overallocating CPUs
```

### High Memory Usage
**Symptoms**: Host running out of RAM

**Solutions**:
```bash
# 1. Check memory usage
free -h

# 2. Enable memory ballooning
qm set <vmid> --balloon 2048

# 3. Check for memory leaks
# Stop non-essential VMs

# 4. Review container limits
pct config <ctid>

# 5. Add swap if needed
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

### System Hangs or Freezes
**Symptoms**: Host becomes unresponsive

**Solutions**:
```bash
# Prevention:
# 1. Enable watchdog
qm set <vmid> --watchdog model=i6300esb,action=reset

# 2. Check for hardware issues
# Run memtest86+ for RAM
# Check disk SMART status

# 3. Review logs after reboot
last reboot
journalctl --since "1 hour ago" | grep -i error

# 4. Disable power saving
# Add to kernel parameters:
intel_idle.max_cstate=0 processor.max_cstate=1
```

---

## Cluster Issues

### Node Cannot Join Cluster
**Symptoms**: Join command fails or node disconnected

**Solutions**:
```bash
# 1. Verify network connectivity
ping other-node-ip

# 2. Check time synchronization
date
timedatectl status

# 3. Verify hostname resolution
cat /etc/hosts
# Ensure all nodes have entries for each other

# 4. Check firewall
# Allow ports: 8006, 5405-5412, 22

# 5. Check corosync
systemctl status corosync
journalctl -u corosync

# 6. Restart cluster services
systemctl restart pve-cluster
systemctl restart corosync
```

### Lost Quorum
**Symptoms**: "Cluster not ready - no quorum"

**Solutions**:
```bash
# 1. Check cluster status
pvecm status

# 2. Identify issue
pvecm nodes

# 3. If majority nodes are down
# On remaining node, set expected votes
pvecm expected 1

# 4. After fixing nodes, restore quorum
pvecm expected <normal-votes>

# 5. For permanent fix
# Always maintain odd number of nodes (3, 5, 7)
```

---

## Web Interface Issues

### Login Failed
**Symptoms**: Cannot login to web interface

**Solutions**:
```bash
# 1. Verify credentials
# Try logging in as root

# 2. Reset root password
# Boot in single user mode
# Or from console:
passwd root

# 3. Check authentication realm
# Should be "Linux PAM standard authentication"

# 4. Check service status
systemctl status pvedaemon
systemctl status pveproxy
```

### "Connection Error" Messages
**Symptoms**: Random disconnections or errors

**Solutions**:
```bash
# 1. Check browser console for errors
# Press F12 in browser

# 2. Clear browser cache and cookies

# 3. Try different browser

# 4. Check certificate
# Regenerate if needed:
pvecm updatecerts

# 5. Check system time
# Ensure time is synchronized
```

---

## Backup and Restore

### Backup Fails
**Symptoms**: vzdump reports errors

**Solutions**:
```bash
# 1. Check disk space
df -h

# 2. Verify backup storage is mounted
pvesm status

# 3. Check backup logs
cat /var/log/vzdump/*

# 4. Try manual backup
vzdump <vmid> --mode snapshot --storage local

# 5. For "No space" errors
# Reduce retention or use compression
vzdump <vmid> --mode snapshot --compress zstd
```

### Restore Fails
**Symptoms**: Cannot restore from backup

**Solutions**:
```bash
# 1. Verify backup file exists
ls -lh /var/lib/vz/dump/

# 2. Check backup integrity
# For .vma files:
vma verify backup.vma

# 3. Ensure target storage has space
df -h

# 4. Try command line restore
qmrestore /path/to/backup.vma <new-vmid>

# 5. For corrupted backups
# Try extracting with vzdump
```

---

## Security and Access

### Locked Out (SSH Key Issues)
**Symptoms**: Cannot SSH into host

**Solutions**:
```bash
# 1. Access via web interface console
# Datacenter -> Node -> Shell

# 2. Check SSH service
systemctl status ssh

# 3. Verify key permissions
ls -la ~/.ssh/
# authorized_keys should be 600

# 4. Check SSH config
cat /etc/ssh/sshd_config
# Verify PubkeyAuthentication yes

# 5. Restart SSH
systemctl restart ssh

# 6. Enable password auth temporarily
nano /etc/ssh/sshd_config
# Set: PasswordAuthentication yes
systemctl restart ssh
```

### Permission Denied Errors
**Symptoms**: Cannot perform actions as user

**Solutions**:
```bash
# 1. Check user permissions
pveum user list

# 2. Check role assignments
pveum acl list

# 3. Assign appropriate role
pveum acl modify / -user user@pam -role PVEAdmin

# 4. For file permissions
ls -la <file>
chmod 755 <file>
```

---

## Advanced Troubleshooting

### Check All Logs
```bash
# System log
tail -f /var/log/syslog

# Proxmox logs
journalctl -xe
journalctl -u pve-cluster -f
journalctl -u pvedaemon -f

# Apache/web logs
tail -f /var/log/apache2/error.log

# Backup logs
ls -lt /var/log/vzdump/
```

### Reset Proxmox Configuration
```bash
# WARNING: This resets Proxmox to defaults
# Backup configs first!

# 1. Stop all VMs and containers
qm list
pct list

# 2. Remove cluster configuration
systemctl stop pve-cluster
rm /etc/pve
rm /etc/corosync/*
systemctl restart pve-cluster

# 3. Re-initialize
pvecreate
```

### Recovery Boot
```bash
# 1. Boot from Proxmox ISO in rescue mode

# 2. Mount root filesystem
mount /dev/pve/root /mnt

# 3. Chroot
chroot /mnt

# 4. Fix issues
# e.g., repair filesystem, reset passwords

# 5. Exit and reboot
exit
umount /mnt
reboot
```

---

## Getting Help

### Before Asking for Help
1. ✅ Check error messages carefully
2. ✅ Review relevant logs
3. ✅ Search [Proxmox Forum](https://forum.proxmox.com/)
4. ✅ Check [Proxmox Wiki](https://pve.proxmox.com/wiki/)
5. ✅ Try safe-mode or minimal configuration

### Information to Provide
When asking for help, include:
- Proxmox version: `pveversion -v`
- Hardware specs (CPU, RAM, disks)
- Network configuration
- Error messages (full text)
- Relevant log excerpts
- Steps to reproduce
- What you've already tried

---

## Related Documentation
- [Quick Start Guide](QUICK_START.md)
- [Best Practices](BEST_PRACTICES.md)
- [Main README](../README.md)

---

[← Back to Main README](../README.md)
