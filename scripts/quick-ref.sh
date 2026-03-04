#!/bin/bash

# Quick reference for common CI/CD tasks

echo "=================================================="
echo "Odoo CI/CD - Quick Reference"
echo "=================================================="
echo ""

case "$1" in
    "vps-setup")
        echo "🚀 Running VPS initial setup..."
        echo "Command: ssh ubuntu@103.180.134.26 'sudo bash < vps-setup.sh'"
        echo ""
        echo "This will:"
        echo "  ✅ Install Docker and Docker Compose"
        echo "  ✅ Create SSH keys for GitHub Actions"
        echo "  ✅ Set up project directories"
        ;;

    "setup-secrets")
        echo "🔐 Setting up GitHub Secrets..."
        echo "Command: bash scripts/setup-ci-cd.sh"
        echo ""
        echo "You'll be prompted for:"
        echo "  - Docker Hub username"
        echo "  - Docker Hub token"
        echo "  - VPS IP address"
        echo "  - VPS SSH port"
        echo "  - VPS username"
        echo "  - SSH private key path"
        ;;

    "deploy-manual")
        echo "🎯 Manual deployment from GitHub..."
        echo ""
        echo "Option 1 - Via GitHub UI:"
        echo "  1. Go to: github.com/YOUR_REPO/actions"
        echo "  2. Select: Build and Deploy Odoo to VPS"
        echo "  3. Click: Run workflow → Run workflow"
        echo ""
        echo "Option 2 - Via GitHub CLI:"
        echo "  gh workflow run deploy.yml --ref main"
        ;;

    "check-status")
        echo "📊 Check deployment status..."
        echo ""
        echo "GitHub Actions:"
        echo "  gh run list --repo YOUR_USERNAME/odoo"
        echo ""
        echo "VPS Services:"
        echo "  ssh ubuntu@103.180.134.26 'docker ps'"
        echo ""
        echo "VPS Logs:"
        echo "  ssh ubuntu@103.180.134.26 'docker-compose logs -f odoo'"
        ;;

    "rollback")
        echo "⏮️  Rollback to previous version..."
        echo ""
        echo "On VPS:"
        echo "  1. Stop current version:"
        echo "     docker-compose down"
        echo ""
        echo "  2. Restore database backup:"
        echo "     docker-compose exec -T db psql -U odoo odoo_db < odoo-backups/backup.sql"
        echo ""
        echo "  3. Restore filestore:"
        echo "     tar -xzf odoo-backups/backup.tar.gz"
        echo ""
        echo "  4. Restart:"
        echo "     docker-compose up -d"
        ;;

    "troubleshoot")
        echo "🔧 Troubleshooting..."
        echo ""
        echo "View workflow errors:"
        echo "  gh run view <RUN_ID> --log"
        echo ""
        echo "SSH to VPS and debug:"
        echo "  ssh ubuntu@103.180.134.26"
        echo "  cd /home/ubuntu/odoo"
        echo "  docker-compose logs -f odoo"
        echo "  docker ps"
        echo ""
        echo "View deployment log:"
        echo "  cat /home/ubuntu/odoo/deployment.log"
        ;;

    "backup-db")
        echo "💾 Manual database backup..."
        echo ""
        echo "ssh ubuntu@103.180.134.26 << 'EOF'"
        echo "  cd /home/ubuntu/odoo"
        echo "  docker-compose exec -T db pg_dump -U odoo odoo_db > backup_manual_\$(date +%Y%m%d_%H%M%S).sql"
        echo "  ls -lh *.sql"
        echo "EOF"
        ;;

    *)
        echo "Available commands:"
        echo ""
        echo "  bash scripts/quick-ref.sh vps-setup       - Initial VPS setup"
        echo "  bash scripts/quick-ref.sh setup-secrets    - Configure GitHub Secrets"
        echo "  bash scripts/quick-ref.sh deploy-manual    - Manual deployment"
        echo "  bash scripts/quick-ref.sh check-status     - Check deployment status"
        echo "  bash scripts/quick-ref.sh rollback         - Rollback to previous version"
        echo "  bash scripts/quick-ref.sh troubleshoot     - Debugging commands"
        echo "  bash scripts/quick-ref.sh backup-db        - Manual database backup"
        echo ""
        echo "Example:"
        echo "  bash scripts/quick-ref.sh vps-setup"
        ;;
esac

echo ""
