#!/bin/bash
set -e

# Write Moodle config.php at container startup using environment variables
cat >/var/www/html/config.php <<EOF
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

// Database
\$CFG->dbtype    = '${MOODLE_DB_TYPE:-mariadb}';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${MOODLE_DB_HOST:-db}';
\$CFG->dbport    = '${MOODLE_DB_PORT:-3306}';
\$CFG->dbname    = '${MOODLE_DB_NAME:-moodle}';
\$CFG->dbuser    = '${MOODLE_DB_USER:-moodle}';
\$CFG->dbpass    = '${MOODLE_DB_PASSWORD}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = [
    'dbcollation' => 'utf8mb4_unicode_ci',
];

// Paths
\$CFG->wwwroot   = '${MOODLE_WWWROOT}';
\$CFG->dataroot  = '${MOODLE_DATAROOT:-/var/moodledata}';
\$CFG->directorypermissions = 02777;

// Cluster / reverse proxy
// nginx terminates TLS and forwards X-Forwarded-Proto: https
\$CFG->reverseproxy    = true;
\$CFG->sslproxy        = true;
\$CFG->cookiesecure    = true;

// Redis session and cache store
\$CFG->session_handler_class = '\core\session\redis';
\$CFG->session_redis_host     = '${REDIS_HOST:-redis}';
\$CFG->session_redis_port     = ${REDIS_PORT:-6379};
\$CFG->session_redis_database = 0;
\$CFG->session_redis_auth     = '${REDIS_PASSWORD:-}';
\$CFG->session_redis_prefix   = 'mdl_sess_';
\$CFG->session_redis_acquire_lock_timeout  = 120;
\$CFG->session_redis_lock_expire           = 7200;
\$CFG->session_redis_serializer_use_igbinary = false;

// Cache store (application cache via Redis)
\$CFG->alternative_cache_factory_classname = null;

// Performance
\$CFG->pathtophp = '/usr/local/bin/php';

require_once(__DIR__ . '/lib/setup.php');
EOF

chown www-data:www-data /var/www/html/config.php
chmod 640 /var/www/html/config.php

# Create moodledata directory if not present
mkdir -p "${MOODLE_DATAROOT:-/var/moodledata}"
chown -R www-data:www-data "${MOODLE_DATAROOT:-/var/moodledata}"
chmod 02777 "${MOODLE_DATAROOT:-/var/moodledata}"

exec "$@"
