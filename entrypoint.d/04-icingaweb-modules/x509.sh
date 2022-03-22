#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Icinga Web 2 Module x509

# Export environment constants
export _ICINGAWEB2_MODULE_X509_INSTALLED_FILE=/etc/icingaweb2/installed_x509

# Default is not installed
export _ICINGAWEB2_MODULE_X509_INSTALLED=false

# Check Icinga Web 2 Module x509 is installed.
if [ -f "$_ICINGAWEB2_MODULE_X509_INSTALLED_FILE" ]; then
    export _ICINGAWEB2_MODULE_X509_INSTALLED=true
fi

# If Icinga Web 2 module x509 (certificate monitoring) is enabled
if $ICINGAWEB2_MODULE_X509; then

    echo "Entrypoint: Create Icinga Web 2 module x509 MySQL Database and User."
    mysql -h$ICINGAWEB2_MYSQL_HOST \
        -P$ICINGAWEB2_MYSQL_PORT \
        -u$MYSQL_ROOT_USER \
        -p$MYSQL_ROOT_PASSWORD \
        -e"CREATE DATABASE IF NOT EXISTS $ICINGAWEB2_MODULE_X509_MYSQL_DB;
           CREATE USER IF NOT EXISTS '$ICINGAWEB2_MODULE_X509_MYSQL_USER'@'%' IDENTIFIED BY '$ICINGAWEB2_MODULE_X509_MYSQL_PASSWORD';
           GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON $ICINGAWEB2_MODULE_X509_MYSQL_DB.* TO '$ICINGAWEB2_MODULE_X509_MYSQL_USER'@'%';"
    
    # If Icinga Web 2 Module x509 is not installed
    if ! $_ICINGAWEB2_MODULE_X509_INSTALLED; then

        # Import the x509 initial schema
        mysql -h$ICINGAWEB2_MYSQL_HOST \
        -P$ICINGAWEB2_MYSQL_PORT \
        -u$MYSQL_ROOT_USER \
        -p$MYSQL_ROOT_PASSWORD \
        $ICINGAWEB2_MODULE_X509_MYSQL_DB < /usr/local/share/icingaweb2/modules/x509/etc/schema/mysql.schema.sql

    fi

    # Enable and setting up Icinga Web 2 module x509.
    echo "Entrypoint: Enable and setting up Icinga Web 2 module x509."
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

    # Touch installed file.
    touch $_ICINGAWEB2_MODULE_X509_INSTALLED_FILE

else

    # Disable Icinga Web 2 module x509.
    echo "Entrypoint: Disable Icinga Web 2 module x509."
    icingacli module disable x509

fi
