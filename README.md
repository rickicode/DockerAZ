# DockerAZ - Docker Manager & Deployment Platform

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Go](https://img.shields.io/badge/go-1.21+-00ADD8.svg)

**DockerAZ** is a comprehensive management platform designed to run as a **native binary** on your host system. It orchestrates Docker containers, manages services, and handles deployments securely and efficiently.

> **📚 Complete Documentation:** Visit **[https://dockeraz.wiki](https://dockeraz.wiki)** for full documentation, guides, and API references.

## ✨ Key Features

- 🐳 **Host-Level Management** - Direct control of the Docker daemon via socket
- 🚀 **Git & Docker Compose Deployment** - Deploy from Git repos or compose files
- 📦 **Template Library** - One-click deployment for popular services
- 🌐 **Auto-SSL & Reverse Proxy** - Integrated Traefik with Let's Encrypt
- ☁️ **Cloudflare Tunnel** - Secure remote access without port forwarding
- 📊 **Resource Monitoring** - Real-time CPU, RAM, and Network stats
- 📂 **File Manager** - Built-in browser for volume management
- 🛡️ **Auto-Recovery** - Automatic health checks and service recovery
- 🔐 **Secure Authentication** - Session-based auth with rate limiting

## 🚀 Quick Start

### Prerequisites

- Linux system (Ubuntu/Debian recommended)
- **Root Access** (Must run as root) - `sudo -i`

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/rickicode/DockerAZ/main/installer.sh | sudo bash
```

After installation, access your dashboard at: **`http://YOUR_SERVER_IP:3012`**

### CLI Commands

```bash
dockeraz                     # Show application info
dockeraz server              # Start the server
dockeraz reset-password      # Reset admin password
dockeraz version             # Show version
dockeraz help                # Show help
```

### Change Port

```bash
# Edit systemd service
sudo nano /etc/systemd/system/dockeraz.service

# Add environment variable
[Service]
Environment="PORT=8080"

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart dockeraz
```

## 📚 Full Documentation

For detailed information, visit:

- **📖 [Documentation](https://dockeraz.wiki)** - Complete guides and tutorials
- **🚀 [Installation Guide](https://dockeraz.wiki)** - Detailed setup instructions
- **⚙️ [Configuration](https://dockeraz.wiki)** - Advanced configuration options
- **❓ [FAQ](https://dockeraz.wiki)** - Common questions and solutions
- **🐛 [Troubleshooting](https://dockeraz.wiki)** - Debug and fix issues

## 📂 Default Locations

| Path | Description |
|---|---|
| `/opt/DockerAZ/data/` | Database and secrets |
| `/opt/DockerAZ/logs/` | Application logs |
| `/opt/DockerAZ/repos/` | Git repositories |
| `/usr/local/bin/dockeraz` | Binary executable |

## 🔧 System Commands

```bash
# View logs (realtime)
sudo journalctl -u dockeraz -f

# Restart service
sudo systemctl restart dockeraz

# Stop service
sudo systemctl stop dockeraz

# Check status
sudo systemctl status dockeraz
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see LICENSE file for details

---

**🔗 Links:**
- [Documentation](https://dockeraz.wiki)
- [GitHub Repository](https://github.com/rickicode/DockerAZ)
- [Report Issues](https://github.com/rickicode/DockerAZ/issues)
- [Releases](https://github.com/rickicode/DockerAZ/releases)
