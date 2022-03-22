#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Database

# Create Icinga Web 2 MySQL Database and User.
echo "Entrypoint: Create Icinga Web 2 MySQL Database and User."
mysql -h$ICINGAWEB2_MYSQL_HOST \
    -P$ICINGAWEB2_MYSQL_PORT \
    -u$MYSQL_ROOT_USER \
    -p$MYSQL_ROOT_PASSWORD \
    -e"CREATE DATABASE IF NOT EXISTS $ICINGAWEB2_MYSQL_DB;
       CREATE USER IF NOT EXISTS '$ICINGAWEB2_MYSQL_USER'@'%' IDENTIFIED BY '$ICINGAWEB2_MYSQL_PASSWORD';
       GRANT ALL ON $ICINGAWEB2_MYSQL_DB . * TO '$ICINGAWEB2_MYSQL_USER'@'%';"

# If Icinga Web 2 is not installed
if ! $_ICINGAWEB2_INSTALLED; then

    # Import the Icinga Web 2 MySQL schema.
    echo "Entrypoint: Import the Icinga Web 2 MySQL schema."
    mysql -h$ICINGAWEB2_MYSQL_HOST \
        -P$ICINGAWEB2_MYSQL_PORT \
        -u$ICINGAWEB2_MYSQL_USER \
        -p$ICINGAWEB2_MYSQL_PASSWORD \
        $ICINGAWEB2_MYSQL_DB < /usr/share/icingaweb2/etc/schema/mysql.schema.sql

fi

echo "Entrypoint: Create Icinga Web 2 administrative user and group."
mysql -h$ICINGAWEB2_MYSQL_HOST \
    -P$ICINGAWEB2_MYSQL_PORT \
    -u$ICINGAWEB2_MYSQL_USER \
    -p$ICINGAWEB2_MYSQL_PASSWORD \
    $ICINGAWEB2_MYSQL_DB \
    -e"INSERT IGNORE INTO icingaweb_group VALUES (1,'Administrators',NULL,NULL,NULL);
       INSERT IGNORE INTO icingaweb_group_membership VALUES (1,'$ICINGAWEB2_ADMIN_USER',NULL,NULL);
       INSERT IGNORE INTO icingaweb_user VALUES ('$ICINGAWEB2_ADMIN_USER',1,'$_ICINGAWEB2_ADMIN_PASSWORD_HASH',NULL,NULL);"




