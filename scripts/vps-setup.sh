#!/bin/bash

# VPS Initial Setup Script
# Run this ONCE on your VPS to prepare it for deployments

set -e

echo "=================================================="
echo "Odoo VPS Initial Setup"
echo "=================================================="
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "❌ This script must be run with sudo"
    exit 1
fi

PROJECT_DIR="/home/ubuntu/odoo"
BACKUP_DIR="/home/ubuntu/odoo-backups"
UBUNTU_USER="ubuntu"

echo "📦 Installing dependencies..."

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Install Git
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    apt-get install -y git
fi

# Add user to docker group
usermod -aG docker "$UBUNTU_USER"

# Create project directories
mkdir -p "$PROJECT_DIR"
mkdir -p "$BACKUP_DIR"
chown -R "$UBUNTU_USER:$UBUNTU_USER" "$PROJECT_DIR" "$BACKUP_DIR"

echo ""
echo "🌐 Verifying Docker installation..."
docker --version
docker-compose --version

echo ""
echo "✅ VPS setup completed!"
echo ""
echo "📝 Manual steps required:"
echo "  1. Clone your repository:"
echo "     cd $PROJECT_DIR"
echo "     git clone https://github.com/YOUR_USERNAME/odoo.git ."
echo ""
echo "  2. Make deploy script executable:"
echo "     chmod +x $PROJECT_DIR/scripts/deploy.sh"
echo ""
echo "  3. Create .env file:"
echo "     cp $PROJECT_DIR/.env.example $PROJECT_DIR/.env"
echo "     # Edit .env as needed"
echo ""
echo "🚀 You're ready for CI/CD deployments!"
echo ""
