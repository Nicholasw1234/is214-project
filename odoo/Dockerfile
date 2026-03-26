FROM odoo:17.0
USER root

# Install system dependencies and Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    gnupg \
    build-essential \
    libxslt1-dev \
    libzip-dev \
    libldap-dev \
    libsasl2-dev \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Install additional Python dependencies for Odoo
# Upgrade gevent to fix compatibility issues with the base image
RUN pip3 install --no-cache-dir --upgrade \
    psycopg2-binary \
    pillow \
    reportlab \
    pyldap \
    vobject \
    xlwt \
    xlrd \
    xlsxwriter \
    openpyxl \
    qrcode \
    python-barcode \
    zeep \
    suds \
    requests \
    urllib3 \
    chardet \
    lxml \
    lxml_html_clean \
    ofxparse \
    gevent

# Copy custom entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create Odoo custom addons directory
RUN mkdir -p /mnt/extra-addons && chown -R odoo:odoo /mnt/extra-addons

USER odoo
VOLUME ["/mnt/extra-addons", "/var/lib/odoo"]
EXPOSE 8069
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["odoo"]
