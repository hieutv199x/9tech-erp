# CI/CD Pipeline Setup Guide for Odoo

This guide explains how to set up the GitHub Actions CI/CD pipeline to automatically build and deploy Odoo to your VPS.

## Overview

The pipeline:
1. **Builds** Docker image on every push to `main` branch
2. **Tests** the Docker build on pull requests
3. **Scans** for security vulnerabilities
4. **Deploys** to VPS automatically on successful builds

## Prerequisites

- GitHub repository with this code
- Docker Hub account (for storing Docker images)
- VPS with Docker and Docker Compose installed
- SSH access to VPS

> This setup uses SSH username/password authentication (`VPS_PASSWORD`) for GitHub Actions deployments.

---

## Step 1: Prepare Your VPS

### Install Docker and Docker Compose

```bash
# SSH to your VPS
ssh ubuntu@103.180.134.26

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose

# Add ubuntu to docker group
sudo usermod -aG docker ubuntu

# Verify installation
docker --version
docker-compose --version

# Create project directory
mkdir -p /home/ubuntu/odoo
cd /home/ubuntu/odoo

# Clone your repository (you'll need to set this up)
git clone https://github.com/YOUR_USERNAME/odoo.git .
```

### Prepare deployment directory

```bash
# Make deploy.sh executable
chmod +x /home/ubuntu/odoo/scripts/deploy.sh
```

---

## Step 2: Set Up GitHub Secrets

### 2.1 Generate Docker Hub Token

1. Go to [Docker Hub](https://hub.docker.com/settings/security)
2. Click "New Access Token"
3. Name it: `github-actions-odoo`
4. Copy the token (you won't see it again)

### 2.2 Add Secrets to GitHub

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret" and add:

| Secret Name | Value |
|-------------|-------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token |
| `VPS_HOST` | `103.180.134.26` |
| `VPS_USER` | `ubuntu` |
| `VPS_PORT` | `22` |
| `VPS_PASSWORD` | VPS login password for `VPS_USER` |

### 2.3 Adding Secrets via GitHub CLI (Optional)

```bash
# Install GitHub CLI if you don't have it
# https://cli.github.com/

# Login to GitHub
gh auth login

# Add secrets
gh secret set DOCKERHUB_USERNAME --body "your_dockerhub_username"
gh secret set DOCKERHUB_TOKEN --body "your_dockerhub_token"
gh secret set VPS_HOST --body "103.180.134.26"
gh secret set VPS_USER --body "ubuntu"
gh secret set VPS_PORT --body "22"
gh secret set VPS_PASSWORD --body "your_vps_user_password"
```

---

## Step 3: Verify Workflow Setup

### 3.1 GitHub Actions Workflow

The workflow file `.github/workflows/deploy.yml` includes:

- **Build Job**: Builds Docker image and pushes to Docker Hub
- **Test Job**: Runs on pull requests to verify build works
- **Security Job**: Scans Docker image for vulnerabilities
- **Deploy Job**: Deploys to VPS (only on main branch)

### 3.2 Test the Pipeline

1. Push a change to your `main` branch:
   ```bash
   git add .
   git commit -m "Trigger CI/CD pipeline"
   git push origin main
   ```

2. Go to: `https://github.com/YOUR_USERNAME/odoo/actions`

3. Watch the workflow execute in real-time

---

## Step 4: Manual Deployment

If you need to deploy manually without pushing code:

1. Go to GitHub Actions tab
2. Select "Build and Deploy Odoo to VPS"
3. Click "Run workflow" → "Run workflow"

Or use GitHub CLI:

```bash
gh workflow run deploy.yml --ref main
```

---

## Step 5: VPS Deployment Process

When the GitHub Action runs, it:

1. **Backs up** current database and filestore
2. **Pulls** latest code from Git
3. **Stops** existing containers
4. **Rebuilds** Docker image
5. **Starts** new containers
6. **Initializes** database (if new)
7. **Health checks** to verify everything works
8. **Cleans up** old backups (keeps 7 days)

All logs are saved to: `/home/ubuntu/odoo/deployment.log`

---

## Monitoring and Troubleshooting

### View Workflow Status

```bash
# Check actions on GitHub
gh run list --repo YOUR_USERNAME/odoo

# View specific run
gh run view <RUN_ID> --repo YOUR_USERNAME/odoo

# View logs
gh run view <RUN_ID> --log --repo YOUR_USERNAME/odoo
```

### SSH to VPS and Check Containers

```bash
# SSH to VPS
ssh ubuntu@103.180.134.26

# Check running containers
docker ps

# View Odoo logs
docker-compose logs -f odoo

# View database logs
docker-compose logs -f db

# Test Odoo is running
curl http://localhost:8069
```

### Database Backups

```bash
# List backups
ls -lh /home/ubuntu/odoo-backups/

# Restore from backup
docker-compose exec -T db psql -U odoo odoo_db < /home/ubuntu/odoo-backups/odoo_db_backup_2024-01-15_10-30-45.sql
```

### Common Issues

#### 1. Docker Build Fails

```bash
# Check Docker logs
docker-compose logs -f

# Rebuild with no cache
docker-compose build --no-cache
```

#### 2. Deployment Script Permission Denied

```bash
# Fix script permissions
chmod +x /home/ubuntu/odoo/scripts/deploy.sh
```

#### 3. SSH Authentication Fails

```bash
# Verify username/password login from your local machine
ssh ubuntu@103.180.134.26

# Confirm the password is updated in GitHub secret VPS_PASSWORD
```

#### 4. Database Connection Error

```bash
# Wait for database to be ready
docker-compose exec -T db pg_isready -U odoo

# Restart database
docker-compose restart db
docker-compose restart odoo
```

---

## Security Best Practices

1. ✅ **Use a strong VPS password** and rotate it regularly
2. ✅ **Rotate tokens** regularly
3. ✅ **Limit secret scope** to only necessary workflows
4. ✅ **Use branch protection** to require checks before merge
5. ✅ **Monitor deployments** via GitHub Actions logs
6. ✅ **Keep backups** of database and filestore
7. ✅ **Use health checks** to catch issues early
8. ✅ **Migrate to SSH keys later** for stronger long-term security

### Enable Branch Protection

1. Go to Settings → Branches
2. Under "Branch protection rules", click "Add rule"
3. Pattern: `main`
4. Enable:
   - Require status checks to pass
   - Require branches to be up to date
   - Include administrators in restrictions

---

## Workflow Configuration Reference

### Docker Image Tagging

Images are tagged as:
- `docker.io/username/odoo-erp:main` (branch name)
- `docker.io/username/odoo-erp:v1.0.0` (version tags)
- `docker.io/username/odoo-erp:latest` (default branch)
- `docker.io/username/odoo-erp:main-abc123def` (commit SHA)

### Environment Variables in Deployment

The workflow sets these environment variables:

```yaml
REGISTRY: docker.io
IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/odoo-erp
VPS_HOST: ${{ secrets.VPS_HOST }}
VPS_USER: ${{ secrets.VPS_USER }}
VPS_PORT: ${{ secrets.VPS_PORT }}
```

---

## Advanced: Custom Deployment Steps

To customize the deployment, edit `.github/workflows/deploy.yml` in the `deploy` job's `script` section.

Example: Add module installation

```yaml
script: |
  set -e
  cd /home/ubuntu/odoo
  git pull origin main
  docker-compose down || true
  docker-compose build --no-cache
  docker-compose up -d
  sleep 5
  
  # Install additional modules
  docker-compose exec -T odoo odoo -d odoo_db -i crm,marketing --stop-after-init
  
  echo "✅ Deployment completed!"
```

---

## Cleanup and Maintenance

### Remove Old Docker Images

```bash
# On VPS
docker image prune -f
docker system prune -a -f
```

### Remove Old Backups

```bash
# Keep only last 30 days
find /home/ubuntu/odoo-backups -mtime +30 -delete
```

### Monitor Disk Usage

```bash
# Check disk space
df -h

# Check Docker disk usage
docker system df
```

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Integration](https://docs.docker.com/docker-hub/)
- [Odoo Deployment Guide](https://www.odoo.com/documentation/19.0/administration/on_premise.html)
- [SSH Key Authentication](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## Support

For issues or questions:
1. Check GitHub Actions logs: Settings → Actions
2. SSH to VPS and check Docker logs
3. Review deployment.log: `/home/ubuntu/odoo/deployment.log`
