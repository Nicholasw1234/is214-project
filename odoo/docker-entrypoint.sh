#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
while ! pg_isready -h "${HOST:-db}" -p "${PORT:-5432}" -U "${USER:-odoo}" -q; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 2
done

echo "PostgreSQL is up - starting Odoo..."

ODOO_WORKERS="${WORKERS:-$(nproc)}"

# Build a merged runtime config that extends /etc/odoo/odoo.conf
# (admin_passwd was removed as a CLI flag in Odoo 17 — must be in a conf file)
cat > /tmp/odoo-runtime.conf <<EOF
[options]
admin_passwd = ${ODOO_ADMIN_PASSWD}

; Trust X-Forwarded-Proto from nginx so Odoo generates https:// URLs
proxy_mode             = True

; Redis session store
session_redis          = True
redis_host             = ${REDIS_HOST:-redis}
redis_port             = ${REDIS_PORT:-6379}
redis_dbindex          = 0
EOF

# Start Odoo — load the shipped base config first, then our runtime overrides
exec odoo \
    --config=/etc/odoo/odoo.conf \
    --config=/tmp/odoo-runtime.conf \
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
    --limit-memory-soft=2147483648 \
    --limit-memory-hard=2684354560 \
    --gevent-port=8072 \
    --data-dir=/var/lib/odoo
