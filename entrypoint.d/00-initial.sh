#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Initial

# If Icinga Web 2 is not installed
if ! $_ICINGAWEB2_INSTALLED; then

    # Copy original Icingaweb2 configs in /etc/icingaweb2.
    echo "Entrypoint: Creating configuration files."
    cp -a /etc/icingaweb2.dist/* /etc/icingaweb2/

fi

# Create log directory /var/log/icingaweb2.
echo "Entrypoint: Create log directory /var/log/icingaweb2."
mkdir -p /var/log/icingaweb2
chown -R www-data:adm /var/log/icingaweb2
