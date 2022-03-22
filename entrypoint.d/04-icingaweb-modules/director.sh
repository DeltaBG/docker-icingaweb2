#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Icinga Web 2 Module Director

# If Icinga Web 2 module Director is enable
if $ICINGAWEB2_MODULE_DIRECTOR; then

    # Create Icinga Web 2 module Director MySQL Database and User.
    echo "Entrypoint: Create Icinga Web 2 module Director MySQL Database and User."
    mysql -h$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_HOST \
        -P$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PORT \
        -u$MYSQL_ROOT_USER \
        -p$MYSQL_ROOT_PASSWORD \
        -e"CREATE DATABASE IF NOT EXISTS $ICINGAWEB2_MODULE_DIRECTOR_MYSQL_DB;
           CREATE USER IF NOT EXISTS '$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_USER'@'%' IDENTIFIED BY '$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PASSWORD';
           GRANT ALL ON $ICINGAWEB2_MODULE_DIRECTOR_MYSQL_DB . * TO '$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_USER'@'%';"


    # If Icinga Web 2 is not installed
    if ! $_ICINGAWEB2_INSTALLED; then

        # Import the Icinga Web 2 module Director MySQL schema.
        echo "Entrypoint: Import the Icinga Web 2 module Director MySQL schema."
        mysql -h$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_HOST \
            -P$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PORT \
            -u$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_USER \
            -p$ICINGAWEB2_MODULE_DIRECTOR_MYSQL_PASSWORD \
            $ICINGAWEB2_MODULE_DIRECTOR_MYSQL_DB < /usr/local/share/icingaweb2/modules/director/schema/mysql.sql

    fi

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

else

    # Disable Icinga Web 2 module Director.
    echo "Entrypoint: Disable Icinga Web 2 module Director."
    icingacli module disable director

fi
