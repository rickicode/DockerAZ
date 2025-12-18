#!/bin/bash

# DockerAZ Installation Script
# IMPORTANT: DockerAZ runs DIRECTLY on host machine - DO NOT run in Docker containers

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default Configuration
REPO="rickicode/DockerAZ"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="dockeraz"
SERVICE_NAME="dockeraz"
DATA_DIR="/opt/DockerAZ"
SERVICE_PORT="3012"
SERVICE_USER="root"

# Show usage
show_usage() {
    cat << EOF
DockerAZ Installation Script

USAGE:
    sudo bash installer.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -d, --dir DIR           Installation directory (default: /usr/local/bin)
    -p, --port PORT         Port for DockerAZ (default: 3012)
    -u, --user USER         Service user (default: root)
    --data-dir DIR          Data directory (default: /opt/DockerAZ)
    --no-service            Don't create systemd service

IMPORTANT:
    - DockerAZ runs DIRECTLY on the host machine
    - DO NOT run DockerAZ inside Docker containers
    - Docker daemon must be installed and running
    - This script MUST be run as root or with sudo

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -d|--dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            -p|--port)
                SERVICE_PORT="$2"
                shift 2
                ;;
            -u|--user)
                SERVICE_USER="$2"
                shift 2
                ;;
            --data-dir)
                DATA_DIR="$2"
                shift 2
                ;;
            --no-service)
                NO_SERVICE=true
                shift
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Parse arguments
parse_args "$@"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}       DockerAZ Installer / Updater     ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Installation Directory: $INSTALL_DIR"
echo -e "  Data Directory: $DATA_DIR"
echo -e "  Port: $SERVICE_PORT"
echo -e "  Service User: $SERVICE_USER"
echo

# 1. Check Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (sudo -i)${NC}"
  exit 1
fi

# Function to get latest version from GitHub
get_latest_version() {
    curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'
}

# Function to get current installed version
get_current_version() {
    if [ -x "$INSTALL_DIR/$BINARY_NAME" ]; then
        $INSTALL_DIR/$BINARY_NAME version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0"
    else
        echo "0.0.0"
    fi
}

# Function to compare versions (returns 0 if $1 > $2)
version_gt() {
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
}

# 2. Check for update mode
echo -e "${GREEN}[+] Checking versions...${NC}"
LATEST_VERSION=$(get_latest_version)
CURRENT_VERSION=$(get_current_version)

echo -e "  ${YELLOW}Current version:${NC} $CURRENT_VERSION"
echo -e "  ${YELLOW}Latest version:${NC}  $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "0.0.0" ]; then
    if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
        echo -e "${GREEN}[✓] You are running the latest version!${NC}"
        echo ""
        read -p "Do you want to reinstall anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}No changes made. Exiting.${NC}"
            exit 0
        fi
    elif version_gt "$LATEST_VERSION" "$CURRENT_VERSION"; then
        echo -e "${YELLOW}[!] New version available! Updating...${NC}"
    fi
fi

# 3. Install Dependencies
echo -e "${GREEN}[+] Installing dependencies (lsof, zip, unzip, curl)...${NC}"
if command -v apt-get &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq lsof zip unzip curl
elif command -v yum &> /dev/null; then
    yum install -y lsof zip unzip curl
elif command -v dnf &> /dev/null; then
    dnf install -y lsof zip unzip curl
elif command -v apk &> /dev/null; then
    apk add --no-cache lsof zip unzip curl
elif command -v pacman &> /dev/null; then
    pacman -Sy --noconfirm lsof zip unzip curl
else
    echo -e "${RED}[!] No package manager found. Please install lsof, zip, unzip, and curl manually.${NC}"
fi

# 4. Install Docker
if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}[+] Installing Docker...${NC}"
    curl -sSL https://get.docker.com | sh
    systemctl start docker && systemctl enable docker
else
    echo -e "${GREEN}[+] Docker already installed.${NC}"
fi

# 5. Detect Architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        BINARY_SUFFIX="amd64"
        ;;
    aarch64)
        BINARY_SUFFIX="arm64"
        ;;
    armv7l)
        BINARY_SUFFIX="armv7"
        ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}[+] Detected architecture: $ARCH ($BINARY_SUFFIX)${NC}"

# 6. Stop service if running (for update)
if systemctl is-active --quiet dockeraz; then
    echo -e "${YELLOW}[+] Stopping existing DockerAZ service...${NC}"
    systemctl stop dockeraz
    echo -e "${GREEN}[+] Sleeping for 3 seconds to ensure shutdown...${NC}"
    sleep 3
fi

# 7. Download Binary
DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/dockeraz-linux-$BINARY_SUFFIX"

echo -e "${GREEN}[+] Downloading DockerAZ from $DOWNLOAD_URL...${NC}"
if curl -sL --fail "$DOWNLOAD_URL" -o "$INSTALL_DIR/$BINARY_NAME"; then
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
    echo -e "${GREEN}[+] Installed to $INSTALL_DIR/$BINARY_NAME${NC}"
else
    echo -e "${RED}[!] Failed to download binary. Please check if release exists.${NC}"
    exit 1
fi

# 8. Verify new version
NEW_VERSION=$(get_current_version)
echo -e "${GREEN}[+] Installed version: $NEW_VERSION${NC}"

# 9. Directories
echo -e "${GREEN}[+] Creating data directories...${NC}"
mkdir -p /opt/DockerAZ/{data,logs,repos}

# 10. Service Installation
echo -e "${GREEN}[+] Installing Systemd Service...${NC}"
cat > /etc/systemd/system/dockeraz.service <<EOF
[Unit]
Description=DockerAZ Manager
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt/DockerAZ
ExecStart=$INSTALL_DIR/$BINARY_NAME server
Restart=always
Environment="PORT=3012"

[Install]
WantedBy=multi-user.target
EOF

# 11. Start Service
echo -e "${GREEN}[+] Starting DockerAZ...${NC}"
systemctl daemon-reload
systemctl enable dockeraz
systemctl restart dockeraz

# 12. Wait for start
sleep 2
SERVICE_STATUS=$(systemctl is-active dockeraz)

if [ "$SERVICE_STATUS" == "active" ]; then
    echo -e "${BLUE}=========================================${NC}"
    if [ "$CURRENT_VERSION" != "0.0.0" ] && [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
        echo -e "${GREEN}SUCCESS! DockerAZ updated: $CURRENT_VERSION -> $NEW_VERSION${NC}"
    else
        echo -e "${GREEN}SUCCESS! DockerAZ is running.${NC}"
    fi
    echo -e "${BLUE}Dashboard: http://$(hostname -I | awk '{print $1}'):3012${NC}"
    echo -e "${BLUE}=========================================${NC}"
else
    echo -e "${RED}Warning: Service status is $SERVICE_STATUS. Check logs with: journalctl -u dockeraz -f${NC}"
fi
