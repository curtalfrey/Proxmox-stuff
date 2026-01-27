# Proxmox-stuff

[![Website](https://img.shields.io/badge/Website-curtisalfrey.com-blue)](https://curtisalfrey.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)

> A comprehensive collection of Proxmox VE configurations, scripts, guides, and best practices for system administrators and homelab enthusiasts.

⭐ **If you find this repository useful, please give it a STAR!** ⭐

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [Features](#features)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Security](#security)
- [Support](#support)
- [License](#license)

---

## 🎯 Overview

This repository contains a curated collection of scripts, configuration files, guides, and best practices for:
- **Proxmox VE** server configuration and management
- **System administration** tasks and automation
- **Container orchestration** with Docker, Portainer, and Kubernetes
- **Security hardening** with ClamAV, RKhunter, and firewall configurations
- **Backup and recovery** strategies
- **Networking** configurations and troubleshooting

---

## 🚀 Quick Start

### For Proxmox Fresh Install
1. Download Proxmox VE ISO from [proxmox.com](https://www.proxmox.com/en/downloads)
2. Create bootable USB using [Etcher](https://www.balena.io/etcher/)
3. Follow the installation guide in [`docs/QUICK_START.md`](docs/QUICK_START.md)
4. Run the MATE desktop installation script from [`proxmox/install_DESKTOP_MATE`](proxmox/install_DESKTOP_MATE)

### For Existing Systems
Browse the relevant sections below to find scripts and guides for your needs.

---

## 📁 Repository Structure

```
.
├── proxmox/              # Proxmox-specific configurations and guides
├── helpful_commands/     # Common commands and scripts
├── ansible/              # Ansible playbooks for automation
├── anti-virus/           # Security scanning tools (ClamAV, RKhunter)
├── cockpit/              # Cockpit web console installation
├── Duplicati/            # Backup solution configurations
├── Kubernetes/           # Kubernetes (K0s) setup guides
├── nginx/                # Nginx Proxy Manager configurations
├── portainer/            # Portainer Docker management
└── docs/                 # Additional documentation
```

---

## ✨ Features

### 🖥️ Proxmox Management
- **Desktop Environment**: MATE GUI installation for direct server access
- **VM Configuration**: Windows 10 VM setup and optimization
- **Storage**: HDD passthrough and formatting guides
- **Networking**: IOMMU configuration and network troubleshooting
- **Cluster Management**: Node deletion and cluster configuration

### 🔧 System Administration
- **SSH Hardening**: Key-based authentication and security configurations
- **Firewall**: UFW configuration and best practices
- **User Management**: Group permissions and sudo access
- **Partitioning**: Disk management and sector calculations
- **File Operations**: Search, copy, and transfer utilities

### 🐳 Container & Orchestration
- **Docker**: Installation scripts and docker-compose files
- **Portainer**: Web-based container management interface
- **Kubernetes**: K0s lightweight Kubernetes distribution
- **Nginx Proxy Manager**: Reverse proxy with Let's Encrypt SSL

### 🔒 Security
- **Anti-Virus**: ClamAV installation and automated scanning
- **Rootkit Detection**: RKhunter configuration and updates
- **IP Banning**: Automated IP blocking for failed login attempts
- **SSH Logs**: Monitoring and analysis scripts
- **Firewall Rules**: UFW configuration examples

### 📦 Backup & Recovery
- **Duplicati**: Automated backup solution setup
- **Backup Scripts**: Custom backup and restore automation
- **Configuration Backup**: System configuration preservation

### 🤖 Automation
- **Ansible Playbooks**: System updates and software installation
- **Cron Jobs**: Scheduled task examples
- **Git Automation**: Repository management and updates
- **Monitoring**: System monitoring stack configuration

---

## 📖 Documentation

### Getting Started Guides
- [Quick Start Guide](docs/QUICK_START.md) - Get up and running fast
- [Best Practices](docs/BEST_PRACTICES.md) - Recommended configurations
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md) - Common issues and solutions

### Detailed Documentation
- **Proxmox Setup**: See [`proxmox/`](proxmox/) directory
- **Docker & Containers**: See [`portainer/`](portainer/) and Docker compose files
- **Security Hardening**: See [`anti-virus/`](anti-virus/) and security scripts
- **Networking**: Various networking guides throughout repository
- **Automation**: See [`ansible/`](ansible/) playbooks

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### How to Contribute
1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-script`)
3. Commit your changes (`git commit -m 'Add amazing script'`)
4. Push to the branch (`git push origin feature/amazing-script`)
5. Open a Pull Request

### What to Contribute
- Bug fixes and improvements
- New scripts and automation
- Documentation enhancements
- Configuration examples
- Best practices and guides

---

## 🔐 Security

- **Review Before Running**: Always review scripts before execution
- **Credential Management**: Never commit passwords or API keys
- **Security Updates**: Keep systems and software up to date
- **Vulnerability Reporting**: See [SECURITY.md](SECURITY.md)

⚠️ **Important**: Scripts in this repository may require sudo/root access. Always understand what a script does before running it.

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/curtalfrey/Proxmox-stuff/issues)
- **Discussions**: [GitHub Discussions](https://github.com/curtalfrey/Proxmox-stuff/discussions)
- **Website**: [curtisalfrey.com](https://curtisalfrey.com)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

Thanks to all contributors and the Proxmox community for their invaluable resources and support.

---

**Made with ❤️ by Curtis Alfrey and contributors**
