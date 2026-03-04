# CI/CD Pipeline Setup - Complete Summary

## ✅ What's Been Created

### 1. GitHub Actions Workflow (`.github/workflows/deploy.yml`)
- **Build Job**: Converts your code into Docker image
- **Test Job**: Runs on pull requests to verify builds work
- **Security Scan**: Scans Docker image for vulnerabilities (using Trivy)
- **Deploy Job**: Automatically deploys to your VPS on successful builds

### 2. Deployment Scripts
- **`scripts/deploy.sh`**: Main deployment script (runs on VPS)
  - Creates backups before deploying
  - Pulls latest code
  - Rebuilds Docker image
  - Starts/restarts containers
  - Health checks
  - Auto-cleanup

- **`scripts/vps-setup.sh`**: VPS initialization (run ONCE)
  - Installs Docker & Docker Compose
  - Prepares VPS runtime for CI/CD deploys
  - Sets up directories
  - Configures permissions

- **`scripts/setup-ci-cd.sh`**: GitHub Secrets setup
  - Interactive script to configure all secrets
  - Works with GitHub CLI

### 3. Configuration Files
- **`docker-compose.yml`**: Multi-container setup
- **`Dockerfile`**: Builds from your source code
- **`docker/odoo.conf`**: Odoo configuration
- **`docker/entrypoint.sh`**: Container startup script
- **`.dockerignore`**: Optimizes Docker build
- **`.env.example`**: Environment variables template

### 4. Documentation
- **`CI_CD_SETUP.md`**: Complete setup guide (40+ steps)
- **`CI_CD_QUICK_START.md`**: Quick reference guide
- **`scripts/quick-ref.sh`**: Helper commands

---

## 🚀 Setup Instructions (30 Minutes)

### Step 1: Prepare Your VPS (5 min)

```bash
# SSH to VPS
ssh ubuntu@103.180.134.26

# Run setup script (install Docker and prepare VPS)
sudo bash << 'EOF'
# Download and run vps-setup.sh
EOF
```

### Step 2: Configure GitHub Repository (10 min)

```bash
# Clone this repository (if not already)
git clone https://github.com/YOUR_USERNAME/odoo.git
cd odoo

# Run the secrets setup script
bash scripts/setup-ci-cd.sh
```

You'll be prompted for:
- Docker Hub username & token
- VPS IP: `103.180.134.26`
- VPS User: `ubuntu`
- VPS Port: `22`
- VPS user password

### Step 3: Test the Pipeline (5 min)

```bash
# Push a test change
git add .
git commit -m "Test CI/CD pipeline"
git push origin main

# Watch deployment in real-time
gh run list
gh run view <RUN_ID> --log

# Or check VPS
ssh ubuntu@103.180.134.26 'docker-compose logs -f odoo'
```

---

## 📊 Pipeline Flow

```
Developer Push to Main
        ↓
GitHub Actions Triggers
        ↓
    ┌─────┬─────┬──────┐
    ↓     ↓     ↓      ↓
  BUILD TEST SCAN  WAIT
    ↓     ↓     ↓      ↓
    └─────┴─────┴──────┘
        ↓
    Deploy to VPS
        ↓
    ├─ Backup Database
    ├─ Backup Filestore
    ├─ Pull Latest Code
    ├─ Build Docker Image
    ├─ Start Containers
    ├─ Health Check
    └─ Success! 🎉
```

---

## 🔑 GitHub Secrets Required

| Secret | Value |
|--------|-------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token |
| `VPS_HOST` | `103.180.134.26` |
| `VPS_USER` | `ubuntu` |
| `VPS_PORT` | `22` |
| `VPS_PASSWORD` | VPS login password for `VPS_USER` |

Setup via:
```bash
# Interactive setup
bash scripts/setup-ci-cd.sh

# Or manually in GitHub:
# Settings → Secrets and variables → Actions → New repository secret
```

---

## 📝 Key Files

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | GitHub Actions workflow (builds & deploys) |
| `scripts/deploy.sh` | Main deployment script for VPS |
| `scripts/vps-setup.sh` | Initial VPS setup (Docker, SSH, etc) |
| `scripts/setup-ci-cd.sh` | Interactive GitHub Secrets configurator |
| `docker-compose.yml` | Local & VPS container orchestration |
| `Dockerfile` | Builds from your Odoo source code |
| `docker/odoo.conf` | Odoo configuration |

---

## 🎯 What Happens on Each Deployment

1. **Backup** - Current database and filestore saved
2. **Pull Code** - Latest changes from Git
3. **Build** - New Docker image created from `Dockerfile`
4. **Deploy** - Stop old containers, start new ones
5. **Initialize** - Database schema created (first time only)
6. **Health Check** - Verify Odoo is responding
7. **Cleanup** - Remove old backups (keeps 7 days)

**Total time**: ~5-10 minutes

---

## 🔍 Monitoring & Troubleshooting

### View Deployment Status

```bash
# GitHub Actions
gh run list --repo YOUR_USERNAME/odoo
gh run view <RUN_ID> --log

# VPS Services
ssh ubuntu@103.180.134.26 'docker ps'
ssh ubuntu@103.180.134.26 'docker-compose logs -f odoo'

# Deployment Log
ssh ubuntu@103.180.134.26 'tail -f /home/ubuntu/odoo/deployment.log'
```

### Common Issues

**Docker build fails**: Check `.dockerignore` isn't excluding needed files

**SSH connection fails**: Verify `VPS_PASSWORD` is correct and the `VPS_USER` can log in via SSH

**Database errors**: Check backups: `ssh ubuntu@103.180.134.26 'ls -la /home/ubuntu/odoo-backups/'`

**Slow deployment**: Docker build is downloading dependencies; use cache layer optimization

### Manual Deployment

```bash
# Via GitHub CLI
gh workflow run deploy.yml --ref main

# Or use GitHub UI:
# Actions → Build and Deploy Odoo to VPS → Run workflow
```

---

## 🚀 Accessing Your Odoo Instance

After successful deployment:

```
🌐 URL: http://103.180.134.26:8069
👤 User: admin
🔐 Password: admin
```

### Change default password IMMEDIATELY:

```bash
# SSH to VPS
ssh ubuntu@103.180.134.26

# Access Odoo container
docker-compose exec odoo bash

# Login to Odoo CLI and change password
# Or use web interface: Settings → Users and Companies → Admin User
```

---

## 🆘 Support & Help

### Quick Reference Commands

```bash
# Check pipeline status
bash scripts/quick-ref.sh check-status

# Manual deployment
bash scripts/quick-ref.sh deploy-manual

# Rollback
bash scripts/quick-ref.sh rollback

# Database backup
bash scripts/quick-ref.sh backup-db

# Troubleshoot
bash scripts/quick-ref.sh troubleshoot
```

### Useful SSH Commands

```bash
# SSH to VPS
ssh ubuntu@103.180.134.26

# Check containers
docker ps
docker-compose status

# View logs
docker-compose logs -f odoo
docker-compose logs -f db

# Restart services
docker-compose restart

# Database access
docker-compose exec db psql -U odoo odoo_db

# Backup manually
docker-compose exec -T db pg_dump -U odoo odoo_db > backup.sql
```

---

## 🔒 Security Best Practices

✅ **Implemented**:
- SSH password authentication via GitHub Secrets
- Health checks before marking successful
- Automatic backups before deployment
- Database isolation in containers
- Secrets managed by GitHub
- Security scanning with Trivy

**Recommended**:
- [ ] Use strong admin password
- [ ] Rotate VPS password regularly
- [ ] Enable GitHub branch protection
- [ ] Monitor GitHub Actions logs
- [ ] Rotate Docker Hub token every 90 days
- [ ] Keep backups in secure location
- [ ] Migrate to SSH key authentication when possible

---

## 📚 Full Documentation

- **[CI_CD_SETUP.md](CI_CD_SETUP.md)** - Complete step-by-step guide
- **[CI_CD_QUICK_START.md](CI_CD_QUICK_START.md)** - Quick reference
- **[DOCKER_GUIDE.md](DOCKER_GUIDE.md)** - Docker configuration details
- **[.github/workflows/deploy.yml](.github/workflows/deploy.yml)** - Workflow definition

---

## 🎯 Next Steps

1. ✅ **Verify VPS setup**: `ssh ubuntu@103.180.134.26 'docker --version'`
2. ✅ **Run secrets setup**: `bash scripts/setup-ci-cd.sh`
3. ✅ **Test deployment**: Push to `main` branch
4. ✅ **Check status**: `gh run list`
5. ✅ **Monitor logs**: `gh run view <RUN_ID> --log`
6. ✅ **Access Odoo**: http://103.180.134.26:8069

---

## 💡 Pro Tips

- Push to `develop` branch for testing (no auto-deploy)
- Only `main` branch triggers automatic deployment
- Check `.dockerignore` to optimize build speed
- Monitor `.log` files for debugging
- Keep backups directory clean: `ssh ubuntu@103.180.134.26 'du -sh /home/ubuntu/odoo-backups/'`

---

**Your CI/CD pipeline is ready! 🎉**

**Start deploying with confidence!**

```bash
git push origin main  # Triggers automatic deployment to VPS
```

---

## Support Channels

- GitHub Actions Logs: https://github.com/YOUR_USERNAME/odoo/actions
- VPS Logs: `/home/ubuntu/odoo/deployment.log`
- Docker Logs: `docker-compose logs -f`
- Odoo Logs: `/var/lib/odoo/logs/`

Questions? Check:
1. GitHub Actions tab for build/deploy errors
2. VPS deployment.log for runtime errors
3. `CI_CD_SETUP.md` for detailed troubleshooting
