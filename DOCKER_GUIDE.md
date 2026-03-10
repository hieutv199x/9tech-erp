# Docker Guide (9Tech ERP)

This project builds an Odoo 19 image from source code in this repository.

## Runtime Paths

Container config file: `docker/odoo.conf`

```ini
[options]
addons_path = /opt/odoo/src/custom_addons,/opt/odoo/src/addons
```

The first path is your product layer (`custom_addons`), while `addons` remains platform source.

## Build Image

```bash
docker build -t 9tech-erp:local .
```

Default startup in this image will auto-install (if not yet installed in the selected DB):

- `muk_web_theme`
- `nine_tech_branding`

You can override with env var:

```bash
-e ODOO_INIT_MODULES="muk_web_theme,nine_tech_branding"
```

The target database is resolved from:

1. `DB_NAME`
2. `POSTGRES_DB`
3. Odoo default behavior (if neither is provided)

## Run With PostgreSQL

Example:

```bash
docker run --rm -it \
  -p 8069:8069 \
  -e HOST=host.docker.internal \
  -e PORT=5432 \
  -e USER=odoo \
  -e PASSWORD=odoo \
  -e DB_NAME=odoo \
  9tech-erp:local
```

## Production Compose

Production deployment uses:

- `deploy/docker-compose.prod.yml`
- `deploy/remote-deploy.sh`

The Odoo service reads external DB settings from env vars:

- `DB_HOST`
- `DB_PORT`
- `DB_USERNAME`
- `DB_PASSWORD`
- `DB_DATABASE`

Then runs with:

```bash
odoo -c /etc/odoo/odoo.conf --db_host=${DB_HOST} --db_port=${DB_PORT} ...
```

## CI/CD (GitHub Actions)

Workflows:

- `.github/workflows/ci.yml`: lint and security scans on PR/push.
- `.github/workflows/dockerhub-image.yml`: build image, push on `main`.
- `.github/workflows/deploy-prod.yml`: deploy to VPS after image workflow succeeds on `main` (or manual dispatch).

Required repository/environment secrets for production deploy:

- `VPS_HOST`
- `VPS_SSH_USER`
- `VPS_SSH_PRIVATE_KEY`
- `VPS_SSH_PORT` (optional, default `22`)
- `PROD_DB_HOST`
- `PROD_DB_PORT` (optional, default `5432`)
- `PROD_DB_USERNAME`
- `PROD_DB_PASSWORD`
- `PROD_DB_DATABASE`
- `PROD_ODOO_DB_FILTER` (optional, default `.*`)
- `PROD_ODOO_HTTP_PORT` (optional, default `8069`)
- `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` (optional for public images)

## Health Check

Deployment health check endpoint:

```text
http://127.0.0.1:${ODOO_HTTP_PORT}/web/login
```

## Troubleshooting

1. Verify addon paths in container:

```bash
docker exec -it <odoo_container> sh -lc 'odoo --version && cat /etc/odoo/odoo.conf'
```

2. Verify custom addons exist in image:

```bash
docker exec -it <odoo_container> ls -la /opt/odoo/src/custom_addons
```
