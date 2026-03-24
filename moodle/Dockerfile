FROM moodlehq/moodle-php-apache:8.3

ARG MOODLE_VERSION=405
ARG MOODLE_RELEASE=4.5.10

# Install system dependencies and PHP extensions required by Moodle 4.5
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libicu-dev \
        libxml2-dev \
        libxslt-dev \
        libldap2-dev \
        libsodium-dev \
        libonig-dev \
        libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        mysqli \
        pdo_mysql \
        soap \
        xsl \
        zip \
        opcache \
        sodium \
        ldap \
        mbstring \
        exif \
        pcntl \
    && rm -rf /var/lib/apt/lists/* /tmp/pear

# Download and extract Moodle from official source
RUN curl -fSL "https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION}/moodle-${MOODLE_RELEASE}.tgz" \
        -o /tmp/moodle.tgz \
    && tar -xzf /tmp/moodle.tgz -C /tmp \
    && cp -r /tmp/moodle/. /var/www/html/ \
    && rm -rf /tmp/moodle /tmp/moodle.tgz

# PHP tuning for Moodle 4.5
RUN { \
        echo 'memory_limit = 512M'; \
        echo 'upload_max_filesize = 512M'; \
        echo 'post_max_size = 512M'; \
        echo 'max_execution_time = 300'; \
        echo 'max_input_vars = 5000'; \
        echo 'default_charset = UTF-8'; \
        echo 'opcache.enable = 1'; \
        echo 'opcache.memory_consumption = 256'; \
        echo 'opcache.max_accelerated_files = 20000'; \
        echo 'opcache.revalidate_freq = 60'; \
        echo 'opcache.use_cwd = 1'; \
        echo 'opcache.validate_timestamps = 1'; \
        echo 'session.cookie_secure = 0'; \
        echo 'session.cookie_httponly = 1'; \
    } > /usr/local/etc/php/conf.d/moodle.ini

# Copy entrypoint that writes config.php at runtime
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set ownership
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

VOLUME ["/var/moodledata"]

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
