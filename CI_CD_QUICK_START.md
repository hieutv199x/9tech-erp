# CI/CD Pipeline Quick Start

## 🚀 Quick Start (5 Minutes)

### 1. VPS Initial Setup (Run ONCE)

```bash
# Option A: Copy and run the setup script
ssh ubuntu@103.180.134.26 << 'EOF'
sudo bash << 'SETUP'
# ... Install Docker and Git
SETUP
EOF

# Option B: Download and run
curl https://your-raw-github-url/scripts/vps-setup.sh | ssh ubuntu@103.180.134.26 sudo bash
```

### 2. Configure GitHub Secrets

```bash
# Run the interactive setup
bash scripts/setup-ci-cd.sh
```

This will prompt for:
- Docker Hub username & token
- VPS IP, port, username
- VPS user password

### 3. Test the Pipeline

```bash
# Push a change to trigger automatic deployment
git add .
git commit -m "Test CI/CD pipeline"
git push origin main

# Or manually trigger via GitHub UI:
# Actions → Build and Deploy Odoo to VPS → Run workflow
```

### 4. Monitor Deployment

```bash
# View in real-time
gh run list --repo YOUR_USERNAME/odoo
gh run view <RUN_ID> --log

# Or check VPS
ssh ubuntu@103.180.134.26 'docker-compose logs -f odoo'
```

---

## 📋 Complete Setup Checklist

- [ ] VPS has Docker & Docker Compose installed
- [ ] VPS username/password SSH access is working
- [ ] GitHub Secrets configured
- [ ] `.github/workflows/deploy.yml` in repository
- [ ] `scripts/deploy.sh` is executable
- [ ] `docker-compose.yml` is configured
- [ ] First deployment tested and working
- [ ] Backup strategy verified

---

## 🔄 Typical Workflow

### For Local Development
```bash
git checkout -b feature/my-change
# make changes
docker-compose up -d
docker-compose logs -f
# test locally

git push origin feature/my-change
# Create pull request on GitHub
# GitHub Actions runs tests
# Review and merge to main
```

### Automatic Deployment
```bash
# After merge to main:
# 1. GitHub Actions builds Docker image
# 2. Pushes to Docker Hub
# 3. Deploys to VPS automatically
# 4. Database backed up
# 5. Health checks verify deployment
```

---

## 🎯 Key Files

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | GitHub Actions workflow |
| `scripts/deploy.sh` | VPS deployment script |
| `scripts/vps-setup.sh` | VPS initialization |
| `scripts/setup-ci-cd.sh` | GitHub Secrets setup |
| `docker-compose.yml` | Container orchestration |
| `Dockerfile` | Docker image definition |

---

## 🆘 Common Tasks

### Manual Deployment
```bash
bash scripts/quick-ref.sh deploy-manual
```

### Check Status
```bash
bash scripts/quick-ref.sh check-status
```

### View Logs
```bash
# GitHub Actions
gh run view <RUN_ID> --log

# VPS
ssh ubuntu@103.180.134.26 tail -f /home/ubuntu/odoo/deployment.log
docker-compose logs -f odoo
```

### Rollback
```bash
bash scripts/quick-ref.sh rollback
```

### Database Backup
```bash
bash scripts/quick-ref.sh backup-db
```

---

## 🔒 Security Tips

1. **Use a strong VPS password**, then rotate it regularly
2. **Rotate Docker Hub token** every 90 days
3. **Keep backups** in secure location
4. **Monitor GitHub Actions** logs for errors
5. **Use branch protection** rules
6. **Limit secret scope** to necessary workflows

---

## 📚 Full Documentation

See `CI_CD_SETUP.md` for complete setup guide including:
- Step-by-step VPS preparation
- GitHub Secrets configuration
- Troubleshooting guide
- Security best practices
- Advanced configuration

---

## 💬 Quick Support

Check these in order:

1. **GitHub Actions Tab**
   - Repository → Actions → Recent runs
   - View logs for build/deploy errors

2. **VPS Logs**
   ```bash
   ssh ubuntu@103.180.134.26
   tail -f /home/ubuntu/odoo/deployment.log
   docker-compose logs -f odoo
   ```

3. **Docker Status**
   ```bash
   ssh ubuntu@103.180.134.26
   docker ps
   docker-compose status
   ```

4. **Backups**
   ```bash
   ssh ubuntu@103.180.134.26
   ls -la /home/ubuntu/odoo-backups/
   ```

---

## 🎬 Next Steps

1. ✅ Run VPS setup: `scripts/vps-setup.sh`
2. ✅ Configure secrets: `scripts/setup-ci-cd.sh`
3. ✅ Test deployment: Push to `main` branch
4. ✅ Monitor: Check GitHub Actions and VPS logs
5. ✅ Celebrate! 🎉

---

**Your CI/CD Pipeline is Ready!**

Push changes → GitHub builds → Automatic deployment → Live!
