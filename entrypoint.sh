#!/bin/bash
# Entrypoint for deltabg/icingaweb2

# Export environment default variables
export DEFAULT_MYSQL_PORT=${DEFAULT_MYSQL_PORT:-3306}
export MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-}

# Export environment variables
export ICINGAWEB2_MYSQL_HOST=${ICINGAWEB2_MYSQL_HOST:-icinga-mariadb}
export ICINGAWEB2_MYSQL_PORT=${ICINGAWEB2_MYSQL_PORT:-${DEFAULT_MYSQL_PORT}}
export ICINGAWEB2_MYSQL_DB=${ICINGAWEB2_MYSQL_DB:-icingaweb2}
export ICINGAWEB2_MYSQL_USER=${ICINGAWEB2_MYSQL_USER:-icingaweb2}
export ICINGAWEB2_MYSQL_PASSWORD=${ICINGAWEB2_MYSQL_PASSWORD:-2bewagnici}

export ICINGA2_MYSQL_HOST=${ICINGA2_MYSQL_HOST:-icinga-mariadb}
export ICINGA2_MYSQL_PORT=${ICINGA2_MYSQL_PORT:-${DEFAULT_MYSQL_PORT}}
export ICINGA2_MYSQL_DB=${ICINGA2_MYSQL_DB:-icinga2}
export ICINGA2_MYSQL_USER=${ICINGA2_MYSQL_USER:-icinga2}
export ICINGA2_MYSQL_PASSWORD=${ICINGA2_MYSQL_PASSWORD:-2agnici}

export ICINGA2_MASTER_CN=${ICINGA2_MASTER_CN:-${ICINGA2_CN}}
export ICINGA2_API_HOST=${ICINGA2_API_HOST:-icinga-icinga2}
export ICINGA2_API_PORT=${ICINGA2_API_PORT:-5665}
export ICINGA2_API_USER=${ICINGA2_API_USER:-icingaweb2}
export ICINGA2_API_PASSWORD=${ICINGA2_API_PASSWORD:-2bewagnici}

export ICINGAWEB2_ADMIN_USER=${ICINGAWEB2_ADMIN_USER:-icingaadmin}
export ICINGAWEB2_ADMIN_PASSWORD=${ICINGAWEB2_ADMIN_PASSWORD:-icinga}

export ICINGAWEB2_SSL=${ICINGAWEB2_SSL:-false}
export ICINGAWEB2_SSL_LETSENCRYPT=${ICINGAWEB2_SSL_LETSENCRYPT:-false}

export ICINGAWEB2_APACHE_SERVER_NAME=${ICINGAWEB2_APACHE_SERVER_NAME:-example.com}
export ICINGAWEB2_APACHE_SERVER_ADMIN=${ICINGAWEB2_APACHE_SERVER_ADMIN:-admin@example.com}

export ICINGAWEB2_MODULE_DIRECTOR=${ICINGAWEB2_MODULE_DIRECTOR:-false}
export ICINGAWEB2_MODULE_DIRECTOR_KICKSTART=${ICINGAWEB2_MODULE_DIRECTOR_KICKSTART:-true}
export ICINGAWEB2_MODULE_DIRECTOR_MYSQL_HOST=${ICINGAWEB2_MODULE_DIRECTOR_MYSQL_HOST:-icinga-mariadb}
export ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PORT=${ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PORT:-${DEFAULT_MYSQL_PORT}}
export ICINGAWEB2_MODULE_DIRECTOR_MYSQL_DB=${ICINGAWEB2_MODULE_DIRECTOR_MYSQL_DB:-icingaweb2_director}
export ICINGAWEB2_MODULE_DIRECTOR_MYSQL_USER=${ICINGAWEB2_MODULE_DIRECTOR_MYSQL_USER:-icingaweb2_director}
export ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PASSWORD=${ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PASSWORD:-rotcerid_2bewagnici}

export ICINGAWEB2_MODULE_GRAPHITE=${ICINGAWEB2_MODULE_GRAPHITE:-false}
export ICINGAWEB2_MODULE_GRAPHITE_HOST=${ICINGAWEB2_MODULE_GRAPHITE_HOST:-icinga-graphite}

export ICINGAWEB2_MODULE_X509=${ICINGAWEB2_MODULE_X509:-false}
export ICINGAWEB2_MODULE_X509_MYSQL_DB=${ICINGAWEB2_MODULE_X509_MYSQL_DB:-x509}
export ICINGAWEB2_MODULE_X509_MYSQL_USER=${ICINGAWEB2_MODULE_X509_MYSQL_USER:-x509}
export ICINGAWEB2_MODULE_X509_MYSQL_PASSWORD=${ICINGAWEB2_MODULE_X509_MYSQL_PASSWORD:-s3cr3tpass}

export ICINGAWEB2_MODULE_GRAFANA=${ICINGAWEB2_MODULE_GRAFANA:-false}
export ICINGAWEB2_MODULE_GRAFANA_HOST=${ICINGAWEB2_MODULE_GRAFANA_HOST:-icinga-grafana}
export ICINGAWEB2_MODULE_GRAFANA_PORT=${ICINGAWEB2_MODULE_GRAFANA_PORT:-3000}
export ICINGAWEB2_MODULE_GRAFANA_PROTOCOL=${ICINGAWEB2_MODULE_GRAFANA_PROTOCOL:-http}
export ICINGAWEB2_MODULE_GRAFANA_TIMERANGE=${ICINGAWEB2_MODULE_GRAFANA_TIMERANGE:-'1w/w'}

# Export environment constants
export _ICINGAWEB2_ADMIN_PASSWORD_HASH=$(openssl passwd -1 "${ICINGAWEB2_ADMIN_PASSWORD}")
export _ICINGAWEB2_INSTALLED_FILE=/etc/icingaweb2/installed

# Default is not installed
export _ICINGAWEB2_INSTALLED=false

# Check Icinga Web 2 is installed.
if [ -f "$_ICINGAWEB2_INSTALLED_FILE" ]; then
    export _ICINGAWEB2_INSTALLED=true
fi

# Run Initial script
/entrypoint.d/00-initial.sh

# Run Database script
/entrypoint.d/01-database.sh

# Run Apache script
/entrypoint.d/02-apache.sh

# Run Icinga Web 2 script
/entrypoint.d/03-icingaweb.sh

# Run Icinga Web 2 Modules scripts
/entrypoint.d/04-icingaweb-modules/director.sh
/entrypoint.d/04-icingaweb-modules/graphite.sh
/entrypoint.d/04-icingaweb-modules/x509.sh
/entrypoint.d/04-icingaweb-modules/grafana.sh

# Run Final script
/entrypoint.d/10-final.sh

# If Icinga Web 2 module Director is enable
if $ICINGAWEB2_MODULE_DIRECTOR; then

    # Run Icinga Web 2 module Director daemon.
    echo "Entrypoint: Run Icinga Web 2 module Director daemon."
    mkdir -p /run/icingaweb2
    icingacli director daemon run &
    echo $! > /run/icingaweb2/director.pid

fi

# Start Apache2 daemon.
echo "Entrypoint: Start Apache2 daemon."
source /etc/apache2/envvars
/usr/sbin/apache2 -DFOREGROUND
