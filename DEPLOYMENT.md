# CI/CD Deployment Guide (GitHub + Docker Hub + VPS)

This repository now includes a full CI/CD baseline:

- CI checks and security scans on PR/push.
- Docker image build and push to Docker Hub on `main`.
- Production deployment to VPS through GitHub Actions over SSH.
- Health-check and rollback on deployment failure.

## Workflows

- `.github/workflows/ci.yml`
  - Ruff lint
  - `pip-audit` dependency scan
  - Trivy filesystem scan
- `.github/workflows/dockerhub-image.yml`
  - Build image on PR
  - Build and push on `main` (`main`, `sha-<commit>`)
  - Trivy image scan (advisory)
- `.github/workflows/deploy-prod.yml`
  - Auto deploy after successful `Docker Image (Docker Hub)` workflow on `main`
  - Manual deploy via `workflow_dispatch` with optional image tag input

## One-Time VPS Setup

Run on VPS:

```bash
sudo bash deploy/vps-bootstrap.sh
```

Then log out and back in.

## Required GitHub Secrets

Already configured:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

Add these secrets for deployment:

- `VPS_HOST`
- `VPS_SSH_USER`
- `VPS_SSH_PRIVATE_KEY`
- `VPS_SSH_PORT` (optional, default `22`)
- `PROD_POSTGRES_DB`
- `PROD_POSTGRES_USER`
- `PROD_POSTGRES_PASSWORD`
- `PROD_ODOO_ADMIN_PASSWD`
- `PROD_ODOO_DB_FILTER` (optional, default `.*`)
- `PROD_ODOO_HTTP_PORT` (optional, default `8069`)

## Production Environment (GitHub)

Create a GitHub Environment named `production` and enable required reviewers
before deploy to enforce manual approval.

## Deploy Files

- `deploy/docker-compose.prod.yml` defines `db` + `odoo`.
- `deploy/remote-deploy.sh` performs pull/up, health check, and rollback.
- `deploy/.env.prod.example` is a reference for runtime values.

## First Deployment Checklist

1. Rotate all exposed credentials (VPS password, DB password, Odoo admin password).
2. Use SSH key auth and disable password SSH login.
3. Push workflow files to `main`.
4. Verify Docker image workflow finishes and image exists in Docker Hub.
5. Approve and run production deploy workflow.
6. Put Nginx/Caddy in front of Odoo and enable TLS.
