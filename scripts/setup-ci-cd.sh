#!/bin/bash

# Quick setup script for CI/CD pipeline
# Run this to set up GitHub Secrets quickly

set -e

echo "=================================================="
echo "Odoo CI/CD Pipeline - Quick Setup"
echo "=================================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if logged in
if ! gh auth status &> /dev/null; then
    echo "🔐 Logging into GitHub..."
    gh auth login
fi

echo "📦 Setting up GitHub Secrets..."
echo ""

# Collect information
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME
read -sp "Enter your Docker Hub token (won't be shown): " DOCKERHUB_TOKEN
echo ""
read -p "Enter VPS IP address (default: 103.180.134.26): " VPS_HOST
VPS_HOST=${VPS_HOST:-103.180.134.26}

read -p "Enter VPS SSH port (default: 22): " VPS_PORT
VPS_PORT=${VPS_PORT:-22}

read -p "Enter VPS username (default: ubuntu): " VPS_USER
VPS_USER=${VPS_USER:-ubuntu}

echo ""
read -sp "Enter VPS user password (won't be shown): " VPS_PASSWORD
echo ""

# Add secrets
echo ""
echo "🔒 Adding secrets to GitHub..."

gh secret set DOCKERHUB_USERNAME --body "$DOCKERHUB_USERNAME"
gh secret set DOCKERHUB_TOKEN --body "$DOCKERHUB_TOKEN"
gh secret set VPS_HOST --body "$VPS_HOST"
gh secret set VPS_USER --body "$VPS_USER"
gh secret set VPS_PORT --body "$VPS_PORT"
gh secret set VPS_PASSWORD --body "$VPS_PASSWORD"

echo ""
echo "✅ GitHub Secrets configured successfully!"
echo ""
echo "📋 Summary:"
echo "  - Docker Hub Username: $DOCKERHUB_USERNAME"
echo "  - VPS Host: $VPS_HOST"
echo "  - VPS User: $VPS_USER"
echo "  - VPS Port: $VPS_PORT"
echo "  - VPS Password: configured"
echo ""
echo "🚀 Next steps:"
echo "  1. Make sure your VPS has Docker installed"
echo "  2. Push code to main branch to trigger deployment"
echo "  3. Check GitHub Actions for deployment status"
echo "  4. Monitor at: https://github.com/YOUR_USERNAME/odoo/actions"
echo ""
