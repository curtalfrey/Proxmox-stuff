# Proxmox Configuration and Setup

This directory contains Proxmox VE-specific configurations, scripts, and guides.

---

## Contents

### Installation and Setup
- **[install_DESKTOP_MATE](install_DESKTOP_MATE)** - Complete script to install MATE desktop environment on Proxmox
  - Includes system updates, user setup, and essential applications
  - Install Docker, security tools (ClamAV, RKhunter)
  - Setup Sublime Text and Sublime Merge

### Networking
- **[NO_MODEM_Proxmox_networking](NO_MODEM_Proxmox_networking)** - Network configuration without modem
- **[IOMMU-config-readme](IOMMU-config-readme)** - IOMMU configuration for PCI passthrough
  - Required for GPU and hardware passthrough to VMs

### Storage
- **[HDD-passthru](HDD-passthru)** - Hard drive passthrough to VMs
  - Direct disk access for VMs
- **[formatting-hdd-ext4](formatting-hdd-ext4)** - Format drives with ext4 filesystem

### Virtual Machines
- **[win10VM_install](win10VM_install)** - Windows 10 VM installation guide
  - Optimal settings for Windows VMs
  - VirtIO drivers setup

### Cluster Management
- **[delete-pvenode](delete-pvenode)** - Remove node from Proxmox cluster
  - Safe node removal procedures

### Security
- **[ssh-harden-vm-in-proxmox](ssh-harden-vm-in-proxmox)** - SSH security hardening
  - Key-based authentication
  - Disable password login
  - Security best practices

---

## Quick Start

### Fresh Proxmox Installation
For a complete setup from scratch, see [install_DESKTOP_MATE](install_DESKTOP_MATE):

```bash
# After installing Proxmox from ISO
# Login as root and run:
./install_DESKTOP_MATE

# This will:
# - Update system
# - Create user account
# - Install MATE desktop
# - Install Docker and essential tools
# - Setup security scanning
# - Install development tools
```

### Hardware Passthrough
For GPU or device passthrough:

1. Enable IOMMU in BIOS
2. Follow [IOMMU-config-readme](IOMMU-config-readme) for kernel configuration
3. Use [HDD-passthru](HDD-passthru) for disk passthrough

### Cluster Setup
When managing Proxmox clusters:
- Use [delete-pvenode](delete-pvenode) to safely remove nodes
- Ensure proper network configuration
- Maintain quorum (odd number of nodes)

---

## Tips

### Desktop Environment
Installing MATE desktop is useful if:
- You need direct access to the server
- You want to manage Proxmox locally
- You need GUI tools for development

### IOMMU/Passthrough
Required for:
- GPU passthrough (gaming VMs, compute)
- Network card passthrough
- Any PCI device direct access

### Storage
- Use ZFS for data integrity and snapshots
- Pass through entire disks for better performance
- Format drives appropriately for your use case

---

## See Also
- [Main README](../README.md)
- [Quick Start Guide](../docs/QUICK_START.md)
- [Best Practices](../docs/BEST_PRACTICES.md)
- [Troubleshooting](../docs/TROUBLESHOOTING.md)

---

[← Back to Main](../README.md)
