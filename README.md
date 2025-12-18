# DockerAZ - Docker Manager & Deployment Platform

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Go](https://img.shields.io/badge/go-1.21+-00ADD8.svg)

DockerAZ is a comprehensive management platform designed to run as a **native binary** on your host system. It orchestrates Docker containers, manages services, and handles deployments securely and efficiently.

**Note:** DockerAZ runs directly on the host (outside of Docker) to ensure maximum compatibility and direct control over the Docker daemon.

## ✨ Features

- 🐳 **Host-Level Management** - Direct control of the Docker daemon via socket.
- 🔄 **Global Deployment History** - Track deployment status and history across all services.
- 🚦 **Traefik Management Dashboard** - Dedicated UI to monitor and control Traefik Proxy.
- 🛡️ **Auto-Recovery System** - Aggressive health checks that automatically resolve port conflicts and restart critical services like Traefik.
- 📉 **Service Stats** - Real-time CPU, RAM, Disk I/O, and Network stats for every container.
- 📂 **File Manager** - Built-in browser to manage volume data and configuration files.
- 🌐 **Auto-SSL & Reverse Proxy** - Integrated Traefik configuration with automatic Let's Encrypt SSL.
- ☁️ **Cloudflare Tunnel** - Seamless integration for secure remote access without port forwarding.
- 🚀 **Zero-Downtime Deployments** - Rolling updates for services.

## 🚀 Installation & Usage

### Prerequisites

- Linux system (Ubuntu/Debian recommended)
- **Root Access** (Must run as root) - `sudo -i`

### One-Click Installation

The easiest way to install DockerAZ is using the automatic installer. This script will:
1. Install dependencies (`lsof`, `zip`, `curl`, etc.)
2. Install Docker (if missing)
3. Download the latest DockerAZ binary for your architecture (AMD64, ARM64, ARMv7)
4. Setup and start the Systemd service

Run as **root**:

```bash
curl -fsSL https://raw.githubusercontent.com/rickicode/DockerAZ/main/installer.sh | sudo bash
```

After installation, access your dashboard at: `http://YOUR_SERVER_IP:3012`

## 🔧 Configuration

DockerAZ uses a persistent SQLite database and local files.

**Default Data Directory:** `/opt/DockerAZ`

| Directory | Purpose |
|---|---|
| `data/` | Database (`dockeraz.db`) and secrets |
| `logs/` | Application and deployment logs |
| `repos/` | Cloned Git repositories |

## 🛠️ Advanced Features

### Traefik Auto-Recovery
DockerAZ includes an aggressive recovery system for the Traefik proxy. On startup:
1. It checks if ports **80**, **443**, and **8080** are free.
2. If blocked, it attempts to **kill the blocking process** automatically.
3. If Traefik is in a bad state, it **force recreates** the container.

### Monitoring
- **Disk Usage**: Monitors host disk usage to prevent "No space left on device" errors.
- **Service Stats**: Detailed resource consumption tables for all running containers.

## ❓ FAQ

### Bagaimana cara reset password/username?

**Cara Termudah (CLI Command):**

```bash
# Stop service terlebih dahulu
sudo systemctl stop dockeraz

# Reset password via CLI
/usr/local/bin/dockeraz reset-password

# Start ulang service
sudo systemctl start dockeraz
```

Sistem akan meminta password baru secara interaktif.

**Alternatif (Hapus Database - reset semua data!):**

```bash
# Stop service
sudo systemctl stop dockeraz

# Hapus database (ini akan menghapus SEMUA data termasuk services!)
sudo rm /opt/DockerAZ/data/dockeraz.db

# Start ulang - akan diminta setup username/password baru
sudo systemctl start dockeraz
```

### CLI Commands

```
dockeraz                     # Tampilkan info aplikasi
dockeraz server              # Jalankan server
dockeraz help                # Tampilkan bantuan lengkap
dockeraz version             # Tampilkan versi
dockeraz reset-password      # Reset password admin

# Environment Variables
PORT=8080 dockeraz server    # Jalankan di port 8080
```

### Port 3012 sudah digunakan, bagaimana cara ganti port?

Edit file service systemd:

```bash
sudo nano /etc/systemd/system/dockeraz.service
```

Tambahkan environment variable `PORT`:

```ini
[Service]
Environment="PORT=8080"
```

Kemudian reload dan restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart dockeraz
```

### Bagaimana cara melihat log error?

```bash
# Log systemd (realtime)
sudo journalctl -u dockeraz -f

# Log file
cat /opt/DockerAZ/logs/dockeraz.log
```

### Traefik tidak bisa start, port 80/443 busy?

DockerAZ memiliki sistem auto-recovery yang akan otomatis kill proses yang menggunakan port tersebut. Jika masih gagal:

```bash
# Cek proses yang menggunakan port
sudo lsof -i :80
sudo lsof -i :443

# Kill manual jika perlu
sudo kill -9 <PID>

# Restart dockeraz
sudo systemctl restart dockeraz
```

### Bagaimana cara update ke versi terbaru?

```bash
# Stop service
sudo systemctl stop dockeraz

# Download binary baru (ganti dengan arsitektur anda: amd64, arm64, armv7)
curl -L https://github.com/rickicode/DockerAZ/releases/latest/download/dockeraz-linux-amd64 -o /usr/local/bin/dockeraz
chmod +x /usr/local/bin/dockeraz

# Start ulang
sudo systemctl start dockeraz
```

### Dimana lokasi file konfigurasi?

| Path | Deskripsi |
|---|---|
| `/opt/DockerAZ/data/dockeraz.db` | Database SQLite (users, services, settings) |
| `/opt/DockerAZ/letsencrypt/acme.json` | SSL certificates dari Let's Encrypt |
| `/opt/DockerAZ/repos/` | Git repositories yang di-clone |
| `/opt/DockerAZ/logs/` | Log files |

### Bagaimana cara backup data?

```bash
# Backup database dan data penting
sudo tar -czvf dockeraz-backup-$(date +%Y%m%d).tar.gz /opt/DockerAZ/data /opt/DockerAZ/letsencrypt
```

### Docker socket permission denied?

DockerAZ harus dijalankan sebagai **root** untuk mengakses Docker socket. Pastikan service berjalan dengan user root:

```bash
# Cek status
sudo systemctl status dockeraz

# Pastikan berjalan sebagai root
ps aux | grep dockeraz
```

## 🤝 Contributing

1. Fork the repo
2. Create feature branch
3. Submit Pull Request

## 📄 License

MIT License