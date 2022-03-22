#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Icinga Web

# Setting up Icinga Web 2 resources.
echo "Entrypoint: Setting up Icinga Web 2 resources."
cat <<EOF > /etc/icingaweb2/resources.ini
[icingaweb2_db]
type = "db"
db = "mysql"
host = "$ICINGAWEB2_MYSQL_HOST"
port = "$ICINGAWEB2_MYSQL_PORT"
dbname = "$ICINGAWEB2_MYSQL_DB"
username = "$ICINGAWEB2_MYSQL_USER"
password = "$ICINGAWEB2_MYSQL_PASSWORD"
charset = "utf8"
use_ssl = "0"

[icinga2_ido]
type = "db"
db = "mysql"
host = "$ICINGA2_MYSQL_HOST"
port = "$ICINGA2_MYSQL_PORT"
dbname = "$ICINGA2_MYSQL_DB"
username = "$ICINGA2_MYSQL_USER"
password = "$ICINGA2_MYSQL_PASSWORD"
charset = "utf8"
use_ssl = "0"

EOF

# Enable and setting up Icinga Web 2 module monitoring.
echo "Entrypoint: Enable Icinga Web 2 module monitoring."
icingacli module enable monitoring
cat <<EOF > /etc/icingaweb2/modules/monitoring/commandtransports.ini
[icinga2]
transport = "api"
host = "$ICINGA2_API_HOST"
port = "$ICINGA2_API_PORT"
username = "$ICINGA2_API_USER"
password = "$ICINGA2_API_PASSWORD"
EOF

# If Icinga Web 2 is not installed
if ! $_ICINGAWEB2_INSTALLED; then

    # Setting up Icinga Web 2 roles.
    echo "Entrypoint: Setting up Icinga Web 2 roles."
    cat <<EOF > /etc/icingaweb2/roles.ini
[Administrators]
users = "$ICINGAWEB2_ADMIN_USER"
permissions = "*"
groups = "Administrators"
EOF

fi

# Enable Icinga Web 2 module doc.
echo "Entrypoint: Enable Icinga Web 2 module doc."
icingacli module enable doc
