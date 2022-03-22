#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Icinga Web 2 Module Graphite

# Export environment constants
export _ICINGAWEB2_MODULE_GRAPHITE_INSTALLED_FILE=/etc/icingaweb2/installed_graphite

# Default is not installed
export _ICINGAWEB2_MODULE_GRAPHITE_INSTALLED=false

# Check Icinga Web 2 Module Graphite is installed.
if [ -f "$_ICINGAWEB2_MODULE_GRAPHITE_INSTALLED_FILE" ]; then
    export _ICINGAWEB2_MODULE_GRAPHITE_INSTALLED=true
fi

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

    # Touch installed file.
    touch $_ICINGAWEB2_MODULE_GRAPHITE_INSTALLED_FILE

else

    # Disable Icinga Web 2 module Graphite.
    echo "Entrypoint: Disable Icinga Web 2 module Graphite."
    icingacli module disable graphite

fi
