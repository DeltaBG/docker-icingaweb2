#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Icinga Web 2 Module Graphite

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

else

    # Disable Icinga Web 2 module Graphite.
    echo "Entrypoint: Disable Icinga Web 2 module Graphite."
    icingacli module disable graphite

fi
