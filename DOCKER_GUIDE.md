# Odoo Docker Configuration Guide

## Official Odoo 19.0 Docker Setup

This is based on the official Odoo Docker repository: https://github.com/odoo/docker/tree/master/19.0

### Key Components

#### 1. **Dockerfile**
- **Base Image**: `ubuntu:noble` (Ubuntu 24.04 LTS)
- **Multi-architecture support**: amd64, arm64, ppc64le
- **Key dependencies**:
  - Python 3.11+ with necessary modules
  - PostgreSQL client
  - wkhtmltopdf (PDF generation)
  - Node.js & npm (CSS compilation via LESS)
  - rtlcss (Right-to-left language support)

#### 2. **entrypoint.sh**
- Handles database connection parameters
- Waits for PostgreSQL to be ready
- Supports environment variables for DB configuration:
  - `DB_PORT_5432_TCP_ADDR` → database host
  - `DB_PORT_5432_TCP_PORT` → database port
  - `DB_ENV_POSTGRES_USER` → database user
  - `DB_ENV_POSTGRES_PASSWORD` → database password

#### 3. **odoo.conf**
Main configuration file with options for:
- `addons_path` - Where custom modules are loaded
- `data_dir` - Odoo data storage location
- `db_*` - Database connection settings
- `workers` - Number of worker threads
- `xmlrpc_port` - Main Odoo web port (8069)
- `xmlrpcs_port` - XML-RPC secure port (8071)
- `longpolling_port` - Real-time updates port (8072)

---

## Using the Docker Setup

### Quick Start

```bash
# Build Docker image
docker-compose build

# Start services
docker-compose up -d

# Initialize database and install modules
docker-compose exec odoo odoo -d odoo_db -i base,sale,stock,account --without-demo=all --stop-after-init
```

### Access Odoo
- **Web**: http://localhost:8069
- **Admin User**: admin / admin (default password)
- **PgAdmin**: http://localhost:5050 (optional)

---

## Architecture

```
Docker Container (Odoo Service)
├── Python 3.11
├── Odoo 19.0 Source Code
├── Custom Addons (/mnt/extra-addons)
├── Configuration (odoo.conf)
└── File Store (/var/lib/odoo)
    │
    └── PostgreSQL Container
        └── Database (odoo_db)
```

---

## Key Docker Features

### 1. **Health Checks**
PostgreSQL includes a health check preventing Odoo from starting until DB is ready:
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U odoo"]
  interval: 10s
  timeout: 5s
  retries: 5
```

### 2. **Volumes**
- `postgres_data`: Database persistence
- `odoo_data`: Filestore (documents, attachments)
- `./addons`: Custom modules mapped to `/mnt/extra-addons`

### 3. **Environment Variables**
```bash
# Database configuration
HOST=db
PORT=5432
USER=odoo
PASSWORD=odoo

# Odoo modes
--dev=all    # Development mode with auto-reload
--without-demo=all  # Disable demo data
```

---

## Common Commands

### Install Modules
```bash
docker-compose exec odoo odoo -d odoo_db -i sale,stock,account
```

### Access Odoo Shell
```bash
docker-compose exec odoo odoo shell -d odoo_db
```

### View Logs
```bash
docker-compose logs -f odoo
```

### Restart Services
```bash
docker-compose restart
```

### Stop All Services
```bash
docker-compose down
```

### Full Clean Reset (⚠️ Deletes database)
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

---

## Your Custom Dockerfile

The provided `Dockerfile` installs Odoo from your **source code** instead of downloading it. This is better for development because:
- Direct access to modify code
- No need to reinstall when files change
- Faster development cycle with `--dev=all` mode

```dockerfile
# Copy Odoo source from host
COPY --chown=odoo:odoo . /odoo/

# Install from source
RUN pip install --no-cache-dir -e /odoo
```

---

## System Requirements

**Minimum**:
- 4GB RAM
- 20GB disk space
- 2 CPU cores

**Recommended**:
- 8GB+ RAM
- 50GB+ disk space
- 4+ CPU cores

---

## Ports Map

| Port | Purpose | URL |
|------|---------|-----|
| 8069 | Main Odoo Web UI | http://localhost:8069 |
| 8071 | XMLRPC Secure | xmlrpcs://localhost:8071 |
| 8072 | WebSocket (Real-time) | ws://localhost:8072 |
| 5432 | PostgreSQL | localhost:5432 |
| 5050 | PgAdmin | http://localhost:5050 |

---

## Troubleshooting

### Database doesn't start
```bash
docker-compose logs db
docker-compose down -v  # Reset database
docker-compose up -d
```

### Port already in use
```bash
# Change ports in docker-compose.yml
# Or kill existing service:
lsof -i :8069
kill -9 <PID>
```

### Module installation fails
```bash
# Check addon path in odoo.conf:
addons_path = /mnt/extra-addons,/odoo/addons

# Verify volumes mounted correctly:
docker-compose exec odoo ls -la /mnt/extra-addons
```

---

## References

- Official Odoo Docker: https://github.com/odoo/docker
- Odoo Documentation: https://www.odoo.com/documentation/19.0/
- Docker Compose Docs: https://docs.docker.com/compose/
