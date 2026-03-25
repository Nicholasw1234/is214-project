#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
while ! pg_isready -h "${HOST:-db}" -p "${PORT:-5432}" -U "${USER:-odoo}" -q; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 2
done

echo "PostgreSQL is up - starting Odoo..."

# Build Odoo command with workers configuration
ODOO_WORKERS="${WORKERS:-$(nproc)}"
ODOO_MAX_WORKERS="${MAX_WORKERS:-$(nproc)}"

# Start Odoo with configuration
exec odoo \
    --database "${ODOO_DATABASE:-odoo}" \
    --db_host="${HOST:-db}" \
    --db_port="${PORT:-5432}" \
    --db_user="${USER:-odoo}" \
    --db_password="${PASSWORD}" \
    --db-filter="${ODOO_DB_FILTER:-.*}" \
    --workers="${ODOO_WORKERS}" \
    --max-cron-threads=2 \
    --limit-time-cpu=600 \
    --limit-time-real=900 \
    --limit-request=10000 \
    --limit-memory-soft=0 \
    --limit-memory-hard=0 \
    --gevent-port=8072 \
    --data-dir=/var/lib/odoo
