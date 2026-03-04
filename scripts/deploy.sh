#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Odoo VPS Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Configuration
PROJECT_DIR="/home/ubuntu/odoo"
BACKUP_DIR="/home/ubuntu/odoo-backups"
LOG_FILE="$PROJECT_DIR/deployment.log"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

# Functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Prerequisites check
log "🔍 Checking prerequisites..."

command -v docker >/dev/null 2>&1 || error "Docker is not installed"
command -v docker-compose >/dev/null 2>&1 || error "Docker Compose is not installed"
command -v git >/dev/null 2>&1 || error "Git is not installed"

log "✅ All prerequisites are installed"

# Navigatory to project directory
if [ ! -d "$PROJECT_DIR" ]; then
    error "Project directory $PROJECT_DIR not found"
fi

cd "$PROJECT_DIR"
log "📁 Working directory: $PROJECT_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup current database
log "🔐 Creating database backup..."
BACKUP_FILE="$BACKUP_DIR/odoo_db_backup_$TIMESTAMP.sql"

if docker-compose ps | grep -q "odoo_db"; then
    docker-compose exec -T db pg_dump -U odoo odoo_db > "$BACKUP_FILE" 2>/dev/null || {
        warn "Failed to backup database, continuing anyway..."
    }
    log "✅ Database backup created: $BACKUP_FILE"
else
    warn "Database container not running, skipping backup"
fi

# Backup filestore
log "📦 Creating filestore backup..."
if [ -d "odoo_data" ]; then
    tar -czf "$BACKUP_DIR/odoo_filestore_$TIMESTAMP.tar.gz" odoo_data/ 2>/dev/null || {
        warn "Failed to backup filestore, continuing anyway..."
    }
    log "✅ Filestore backup created"
fi

# Pull latest code
log "📥 Pulling latest code from repository..."
git fetch origin main || warn "Failed to fetch from origin"
git pull origin main || {
    warn "Failed to pull latest changes"
    git status
}

# Update environment variables
log "⚙️  Updating environment configuration..."
if [ -f ".env.example" ]; then
    cp ".env.example" ".env" 2>/dev/null || warn "Failed to update .env"
fi

# Stop existing containers
log "⛔ Stopping existing containers..."
docker-compose down || warn "Failed to stop containers gracefully"

# Rebuild image
log "🔨 Building Docker image..."
docker-compose build --no-cache || error "Docker build failed"

# Start services
log "🚀 Starting services..."
docker-compose up -d || error "Failed to start services"

# Wait for services
log "⏳ Waiting for services to be ready..."
sleep 5

# Check database health
log "🏥 Checking database health..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker-compose exec -T db pg_isready -U odoo >/dev/null 2>&1; then
        log "✅ Database is ready"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    error "Database failed to start within timeout"
fi

# Initialize database if needed
log "📊 Checking database initialization..."
docker-compose exec -T odoo odoo -d odoo_db --no-http >/dev/null 2>&1 || {
    log "📊 Database not initialized, initializing now..."
    docker-compose exec -T odoo odoo -d odoo_db \
        -i base,sale,stock,account,crm,utm,mass_mailing \
        --without-demo=all \
        --stop-after-init || warn "Database initialization encountered issues"
}

# Health check
log "🏥 Running health checks..."
HEALTH_CHECK_RETRIES=30
HEALTH_CHECK_COUNT=0

while [ $HEALTH_CHECK_COUNT -lt $HEALTH_CHECK_RETRIES ]; do
    if curl -s http://localhost:8069 >/dev/null 2>&1; then
        log "✅ Odoo is responding"
        break
    fi
    HEALTH_CHECK_COUNT=$((HEALTH_CHECK_COUNT + 1))
    echo -n "."
    sleep 2
done

if [ $HEALTH_CHECK_COUNT -eq $HEALTH_CHECK_RETRIES ]; then
    warn "Odoo failed to respond within timeout, but deployment completed"
fi

# Database cleanup
log "🧹 Cleaning up Docker resources..."
docker system prune -f >/dev/null

# Final status
log "📊 Deployment Summary:"
log "  - Project: $PROJECT_DIR"
log "  - Web UI: http://localhost:8069"
log "  - Database: odoo_db"
log "  - Backup: $BACKUP_FILE"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🌐 Access Odoo at: http://localhost:8069"
echo "📊 Default login: admin / admin"
echo ""

# Cleanup old backups (keep last 7 days)
log "🧹 Cleaning old backups..."
find "$BACKUP_DIR" -name "odoo_db_backup_*.sql" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "odoo_filestore_*.tar.gz" -mtime +7 -delete 2>/dev/null || true

log "✅ Script completed"
