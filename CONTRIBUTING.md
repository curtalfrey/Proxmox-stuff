# Contributing to Proxmox-stuff

First off, thank you for considering contributing to this repository! 🎉

This project aims to be a helpful collection of Proxmox-related resources, scripts, and documentation. Your contributions make this resource better for everyone.

---

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Contribution Guidelines](#contribution-guidelines)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)

---

## Code of Conduct

### Our Pledge
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior
- Harassment, discrimination, or personal attacks
- Publishing others' private information
- Trolling or insulting/derogatory comments
- Other unprofessional conduct

---

## How Can I Contribute?

### 🐛 Reporting Bugs
If you find a bug in a script or documentation:

1. **Check existing issues** to avoid duplicates
2. **Use the issue template** if available
3. **Include details**:
   - What you expected to happen
   - What actually happened
   - Steps to reproduce
   - Your environment (Proxmox version, OS, etc.)
   - Error messages or logs

### 💡 Suggesting Enhancements
Have an idea for improvement?

1. **Check existing suggestions** first
2. **Open an issue** with the `enhancement` label
3. **Describe**:
   - The problem you're trying to solve
   - Your proposed solution
   - Why this would be useful to others

### 📝 Improving Documentation
Documentation improvements are always welcome!

- Fix typos or unclear explanations
- Add missing information
- Improve examples
- Translate content (if multilingual support is added)

### 🔧 Contributing Scripts or Configurations
Adding new scripts or configurations:

1. Ensure it's useful for the community
2. Test thoroughly before submitting
3. Include clear documentation
4. Follow existing patterns and structure

---

## Getting Started

### Fork and Clone
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR-USERNAME/Proxmox-stuff.git
cd Proxmox-stuff

# Add upstream remote
git remote add upstream https://github.com/curtalfrey/Proxmox-stuff.git
```

### Create a Branch
```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### Make Your Changes
- Follow the style guidelines below
- Test your changes
- Update documentation as needed

### Commit and Push
```bash
# Commit your changes
git add .
git commit -m "Description of changes"

# Push to your fork
git push origin feature/your-feature-name
```

### Open a Pull Request
1. Go to the original repository on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill out the PR template
5. Submit!

---

## Contribution Guidelines

### General Guidelines
- ✅ **DO**: Test your changes before submitting
- ✅ **DO**: Update documentation to match code changes
- ✅ **DO**: Keep changes focused and atomic
- ✅ **DO**: Add comments for complex logic
- ✅ **DO**: Check for existing similar contributions
- ❌ **DON'T**: Submit untested code
- ❌ **DON'T**: Include unrelated changes
- ❌ **DON'T**: Submit proprietary or licensed code without permission

### File Organization
```
Proxmox-stuff/
├── docs/                   # Documentation files
├── proxmox/               # Proxmox-specific scripts and guides
├── helpful_commands/      # General command references and scripts
├── ansible/               # Ansible playbooks
├── anti-virus/            # Security tools
├── [service-name]/        # Service-specific directories
└── README.md              # Main documentation
```

### Where to Add Your Contribution

#### Scripts
- **Proxmox-specific**: `proxmox/`
- **General utilities**: `helpful_commands/`
- **Service-specific**: Appropriate service directory (e.g., `docker/`, `kubernetes/`)

#### Documentation
- **Getting started guides**: `docs/`
- **Service-specific docs**: In the service directory with a README.md
- **Command references**: `helpful_commands/`

#### Configuration Files
- **Docker**: `[service]/docker-compose.yml`
- **Ansible**: `ansible/playbooks/`
- **Config files**: In appropriate service directory

---

## Style Guidelines

### Shell Scripts
```bash
#!/bin/bash
# Description: What this script does
# Author: Your Name (optional)
# Date: YYYY-MM-DD (optional)

# Use meaningful variable names
BACKUP_DIR="/var/backups"
LOG_FILE="/var/log/script.log"

# Add comments for complex operations
# This function checks if service is running
check_service() {
    systemctl is-active --quiet "$1"
}

# Use error checking
if [ $? -ne 0 ]; then
    echo "Error: Command failed"
    exit 1
fi

# Make scripts executable
chmod +x script.sh
```

### Documentation (Markdown)
```markdown
# Use Clear Headings

## Level 2 Heading

### Level 3 Heading

- Use bulleted lists for non-sequential items
1. Use numbered lists for sequential steps

**Bold** for emphasis
`code` for commands or code snippets

## Code Blocks
\`\`\`bash
# Always specify language for syntax highlighting
command --with-options
\`\`\`

## Links
[Link Text](https://url)
[Local Link](./relative/path.md)
```

### Configuration Files
```yaml
# Add comments explaining non-obvious settings
services:
  app:
    image: nginx:latest
    # Use specific versions in production
    ports:
      - "80:80"
    # Document port mappings
```

### Naming Conventions
- **Files**: Use lowercase with hyphens: `my-script.sh`, `config-file.yml`
- **Directories**: Lowercase, descriptive: `helpful_commands`, `anti-virus`
- **Scripts**: Should end with `.sh` if shell script
- **Documentation**: Use `.md` for Markdown files

---

## Commit Messages

### Format
```
<type>: <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes (no code change)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples
```bash
# Good commit messages
git commit -m "feat: Add automated backup script for VMs"
git commit -m "fix: Correct network configuration in docker-compose"
git commit -m "docs: Update quick start guide with troubleshooting section"

# Bad commit messages
git commit -m "update"
git commit -m "fixed stuff"
git commit -m "changes"
```

### Guidelines
- ✅ Use present tense: "Add feature" not "Added feature"
- ✅ Be specific: "Fix SSH timeout in login script" not "Fix bug"
- ✅ Reference issues: "Fixes #123: Add missing dependency"
- ✅ Keep first line under 72 characters

---

## Pull Request Process

### Before Submitting
1. ✅ Update README.md if adding new major features
2. ✅ Add or update documentation
3. ✅ Test your changes thoroughly
4. ✅ Ensure no sensitive information (passwords, API keys)
5. ✅ Sync with upstream: `git pull upstream main`

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Configuration change

## Testing
Describe how you tested these changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No sensitive information included
- [ ] Changes are focused and atomic
```

### Review Process
1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. Celebrate! 🎉

### After Merge
```bash
# Update your local repository
git checkout main
git pull upstream main

# Delete your feature branch (optional)
git branch -d feature/your-feature-name
```

---

## What Makes a Good Contribution?

### ✅ Good Examples
- **Well-documented script** with clear comments and usage instructions
- **Tested configuration** that works on a clean install
- **Comprehensive guide** that walks through a process step-by-step
- **Bug fix** with explanation of the problem and solution
- **Improvement** that makes existing content clearer or more useful

### ❌ What to Avoid
- **Untested code** that may not work
- **Poorly documented** scripts without comments or usage info
- **Security risks** like hardcoded passwords or keys
- **Duplicate content** without adding value
- **Overly specific** solutions that only work in one environment

---

## Questions or Need Help?

- 💬 **GitHub Discussions**: For questions and community discussion
- 🐛 **GitHub Issues**: For bug reports and feature requests
- 📧 **Contact**: Check README for contact information

---

## Recognition

Contributors will be:
- Listed in commit history
- Acknowledged in release notes (for significant contributions)
- Given credit in comments if they request it

---

## License

By contributing, you agree that your contributions will be licensed under the same MIT License that covers this project.

---

Thank you for contributing! Your efforts help make this resource better for everyone in the Proxmox community. 🙏
