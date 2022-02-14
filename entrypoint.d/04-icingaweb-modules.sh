#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Icinga Web 2 Modules

# If Icinga Web 2 module Graphite is enable
if $ICINGAWEB2_MODULE_GRAPHITE; then

    # Enable and setting up Icinga Web 2 module Graphite.
    echo "Entrypoint: Enable and setting up Icinga Web 2 module Graphite."
    icingacli module enable graphite
    cp -a /usr/local/share/icingaweb2/modules/graphite/templates/* /etc/icingaweb2/modules/graphite
    cat <<EOF > /etc/icingaweb2/modules/graphite/config.ini
[graphite]
url = "http://$ICINGAWEB2_MODULE_GRAPHITE_HOST/"
insecure = "0"
EOF

fi

# If Icinga Web 2 module Director is enable
if $ICINGAWEB2_MODULE_DIRECTOR; then

    # Enable and setting up Icinga Web 2 module Incubator.
    echo "Entrypoint: Enable and setting up Icinga Web 2 module Incubator."
    icingacli module enable incubator

    # Enable and setting up Icinga Web 2 module Director.
    echo "Entrypoint: Enable and setting up Icinga Web 2 module Director."
    icingacli module enable director

    # Setting up Icinga Web 2 module Director resources.
    echo "Entrypoint: Setting up Icinga Web 2 module Director resources."
    cat <<EOF >> /etc/icingaweb2/resources.ini
[director_db]
type = "db"
db = "mysql"
host = "$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_HOST"
port = "$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PORT"
dbname = "$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_DB"
username = "$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_USER"
password = "$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PASSWORD"
charset = "utf8"
use_ssl = "0"
EOF

    # If Icinga Web 2 module Director Kickstart is enable
    if $ICINGAWEB2_MODULE_DIRECTOR_KICKSTART; then

        # Setting up Icinga Web 2 module Director kickstart.
        echo "Entrypoint: Setting up Icinga Web 2 module Director kickstart."
        cat <<EOF > /etc/icingaweb2/modules/director/kickstart.ini
[config]
endpoint = "$ICINGA2_MASTER_CN"
host = "$ICINGA2_API_HOST"
port = $ICINGA2_API_PORT
username = "$ICINGA2_API_USER"
password = "$ICINGA2_API_PASSWORD"
EOF

        # Run Icinga Web 2 module Director kickstart.
        echo "Entrypoint: Run Icinga Web 2 module Director kickstart."
        icingacli director kickstart run

    fi

fi

# If Icinga Web 2 module x509 (certificate monitoring) is enabled
if $ICINGAWEB2_MODULE_X509; then

    # Enable the x509 module
    icingacli module enable x509

    # Setup x509 resources.ini
    cat <<EOF >> /etc/icingaweb2/resources.ini
[x509_db]
type = "db"
db = "mysql"
host = "$ICINGAWEB2_MYSQL_HOST"
port = "$ICINGAWEB2_MYSQL_PORT"
dbname = "$ICINGAWEB2_MODULE_X509_MYSQL_DB"
username = "$ICINGAWEB2_MODULE_X509_MYSQL_USER"
password = "$ICINGAWEB2_MODULE_X509_MYSQL_PASSWORD"
charset = "utf8"
use_ssl = "0"
EOF

    # Run initial CA certificates import
    icingacli x509 import --file /etc/ssl/certs/ca-certificates.crt

fi
