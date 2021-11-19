#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Final

# Repair configuration directory permission.
echo "Entrypoint: Repair configuration directory permission."
chmod 2770 /etc/icingaweb2
chmod 0640 /etc/icingaweb2/resources.ini
chown -R root:icingaweb2 /etc/icingaweb2
chown -R root:root /etc/apache2/ssl
chown -R root:adm /var/log/apache2

# Initial setup is done. Touch installed file.
echo "Entrypoint: Initial setup is done."
touch $_ICINGAWEB2_INSTALLED_FILE
