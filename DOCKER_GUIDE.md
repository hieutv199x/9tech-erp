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
