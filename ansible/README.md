# Ansible Automation

Ansible playbooks and configurations for automated system management.

---

## What is Ansible?

Ansible is an automation tool for:
- **Configuration Management**: Keep systems configured consistently
- **Application Deployment**: Deploy applications and updates
- **Task Automation**: Automate repetitive tasks
- **Orchestration**: Coordinate complex multi-system tasks

Benefits:
- Agentless (uses SSH)
- Simple YAML syntax
- Idempotent operations
- Large module library

---

## Contents

### [docker-compose.yml](docker-compose.yml)
Run Ansible in a Docker container
- No need to install Ansible on host
- Consistent environment
- Easy version management

### [playbooks/](playbooks/)
Collection of ready-to-use Ansible playbooks:

#### [apt-update-upgrade.yml](playbooks/apt-update-upgrade.yml)
Update and upgrade all packages on Debian/Ubuntu systems

#### [github-repo-update](playbooks/github-repo-update)
Automatically clone or fast-forward Git repositories (`ansible.builtin.git`).
Each entry in `repositories` needs `name`, `url` and `path`; `branch` defaults to `main`.
Use SSH urls with a deploy key for private repos.

#### [install-new-vm-programs](playbooks/install-new-vm-programs)
Install standard software on new VMs
- Common utilities
- Development tools
- System packages

---

## Quick Start

### Install Ansible

#### On Debian/Ubuntu
```bash
apt update
apt install ansible -y

# Verify installation
ansible --version
```

#### Using Docker
```bash
cd /path/to/Proxmox-stuff/ansible
docker-compose up -d
```

### Basic Configuration

#### Create Inventory File
```bash
# Create inventory of your servers
nano inventory.ini
```

```ini
[webservers]
web1.example.com
web2.example.com

[databases]
db1.example.com

[proxmox]
pve1.local ansible_host=192.168.1.100
pve2.local ansible_host=192.168.1.101

[all:vars]
ansible_user=root
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

#### Test Connection
```bash
ansible all -i inventory.ini -m ping
```

---

## Using Playbooks

### System Updates
Update all systems:
```bash
cd /path/to/Proxmox-stuff/ansible

# Run update playbook
ansible-playbook -i inventory.ini playbooks/apt-update-upgrade.yml

# Limit to specific hosts
ansible-playbook -i inventory.ini playbooks/apt-update-upgrade.yml --limit webservers

# Dry run (check mode)
ansible-playbook -i inventory.ini playbooks/apt-update-upgrade.yml --check
```

### Install Software
Install programs on new VMs:
```bash
ansible-playbook -i inventory.ini playbooks/install-new-vm-programs
```

### Update Git Repositories
Keep repositories up to date:
```bash
ansible-playbook -i inventory.ini playbooks/github-repo-update
```

---

## Creating Custom Playbooks

### Basic Playbook Structure
```yaml
---
# playbook-name.yml
- name: Description of what this playbook does
  hosts: all  # or specific group
  become: yes  # Run as sudo
  
  tasks:
    - name: Task description
      module_name:
        parameter: value
```

### Example: Install Docker
```yaml
---
- name: Install Docker on Ubuntu
  hosts: all
  become: yes
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
    
    - name: Install required packages
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
        state: present
    
    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present
    
    - name: Add Docker repository
      apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu focal stable
        state: present
    
    - name: Install Docker
      apt:
        name: docker-ce
        state: present
    
    - name: Ensure Docker is started
      service:
        name: docker
        state: started
        enabled: yes
```

### Example: Configure SSH
```yaml
---
- name: Harden SSH Configuration
  hosts: all
  become: yes
  
  tasks:
    - name: Disable root login
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'
        state: present
    
    - name: Disable password authentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PasswordAuthentication'
        line: 'PasswordAuthentication no'
        state: present
    
    - name: Restart SSH service
      service:
        name: ssh
        state: restarted
```

---

## Common Ansible Modules

### Package Management
```yaml
# APT (Debian/Ubuntu)
- name: Install package
  apt:
    name: nginx
    state: present

# YUM/DNF (RedHat/CentOS)
- name: Install package
  yum:
    name: nginx
    state: present
```

### File Operations
```yaml
# Copy file
- name: Copy configuration
  copy:
    src: /local/path/config.conf
    dest: /remote/path/config.conf
    mode: '0644'

# Create directory
- name: Create directory
  file:
    path: /var/www/html
    state: directory
    mode: '0755'

# Download file
- name: Download file
  get_url:
    url: https://example.com/file.tar.gz
    dest: /tmp/file.tar.gz
```

### Service Management
```yaml
- name: Ensure service is running
  service:
    name: nginx
    state: started
    enabled: yes

- name: Restart service
  service:
    name: apache2
    state: restarted
```

### User Management
```yaml
- name: Create user
  user:
    name: deploy
    groups: sudo
    shell: /bin/bash
    state: present

- name: Add SSH key
  authorized_key:
    user: deploy
    key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
```

### Command Execution
```yaml
- name: Run command
  command: /usr/bin/some-command

- name: Run shell command
  shell: echo "Hello" > /tmp/file.txt

- name: Run script
  script: /path/to/local/script.sh
```

---

## Best Practices

### ✅ Do This
1. **Use version control** for playbooks
2. **Test in staging** before production
3. **Use --check mode** for dry runs
4. **Keep playbooks idempotent** (can run multiple times)
5. **Use roles** for complex configurations
6. **Document playbooks** with comments
7. **Use variables** for flexibility
8. **Use vault** for sensitive data

### Variables
```yaml
---
- name: Use variables
  hosts: all
  vars:
    app_name: myapp
    app_port: 8080
  
  tasks:
    - name: Install {{ app_name }}
      apt:
        name: "{{ app_name }}"
```

### Ansible Vault (for secrets)
```bash
# Create encrypted file
ansible-vault create secrets.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Run playbook with vault
ansible-playbook playbook.yml --ask-vault-pass
```

---

## Advanced Features

### Roles
Organize playbooks into reusable roles:
```
roles/
  webserver/
    tasks/
      main.yml
    handlers/
      main.yml
    templates/
    files/
    vars/
      main.yml
```

### Templates (Jinja2)
```yaml
# Use template
- name: Deploy config from template
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
```

### Handlers
```yaml
tasks:
  - name: Copy nginx config
    copy:
      src: nginx.conf
      dest: /etc/nginx/nginx.conf
    notify: restart nginx

handlers:
  - name: restart nginx
    service:
      name: nginx
      state: restarted
```

### Tags
```yaml
tasks:
  - name: Install packages
    apt:
      name: nginx
    tags: install

# Run only tagged tasks
ansible-playbook playbook.yml --tags install
```

---

## Scheduling with Cron

```bash
# Run playbook daily at 2 AM
crontab -e
0 2 * * * ansible-playbook -i /path/to/inventory.ini /path/to/playbook.yml
```

---

## Troubleshooting

### Connection Issues
```bash
# Test connection
ansible all -i inventory.ini -m ping -vvv

# Check SSH config
ansible all -i inventory.ini -m setup --limit hostname

# Use specific SSH key
ansible-playbook playbook.yml --private-key ~/.ssh/custom_key
```

### Common Errors
```bash
# "Host unreachable"
# Check: SSH access, firewall, IP address

# "Permission denied"
# Check: SSH keys, ansible_user, become settings

# "Module not found"
# Update Ansible: apt install --upgrade ansible
```

### Debug Mode
```bash
# Verbose output
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vv
ansible-playbook playbook.yml -vvv  # Very verbose

# Step-by-step
ansible-playbook playbook.yml --step

# Start at specific task
ansible-playbook playbook.yml --start-at-task="Task name"
```

---

## Useful Commands

```bash
# List all hosts
ansible all -i inventory.ini --list-hosts

# Gather facts
ansible all -i inventory.ini -m setup

# Run ad-hoc command
ansible all -i inventory.ini -a "uptime"

# Check playbook syntax
ansible-playbook playbook.yml --syntax-check

# List tasks
ansible-playbook playbook.yml --list-tasks

# List tags
ansible-playbook playbook.yml --list-tags
```

---

## See Also
- [System Scripts](../helpful_commands/scripts/)
- [Proxmox Configuration](../proxmox/)
- [Best Practices](../docs/BEST_PRACTICES.md)

### Official Resources
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Pre-made roles
- [Ansible Examples](https://github.com/ansible/ansible-examples)

---

[← Back to Main](../README.md)
