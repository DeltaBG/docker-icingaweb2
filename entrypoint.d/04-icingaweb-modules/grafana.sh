#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Icinga Web 2 Module Grafana

# Export environment constants
export _ICINGAWEB2_MODULE_GRAFANA_INSTALLED_FILE=/etc/icingaweb2/installed_grafana

# Default is not installed
export _ICINGAWEB2_MODULE_GRAFANA_INSTALLED=false

# Check Icinga Web 2 Module Director is installed.
if [ -f "$_ICINGAWEB2_MODULE_GRAFANA_INSTALLED_FILE" ]; then
    export _ICINGAWEB2_MODULE_GRAFANA_INSTALLED=true
fi

if $ICINGAWEB2_MODULE_GRAFANA; then


    # Enable and set up Icinga Web 2 module Grafana.
    echo "Entrypoint: Enable and set up Icinga Web 2 module Grafana."
	icingacli module enable grafana
    cat <<EOF > /etc/icingaweb2/modules/grafana/config.ini
[grafana]
host = "$ICINGAWEB2_MODULE_GRAFANA_HOST:$ICINGAWEB2_MODULE_GRAFANA_PORT"
protocol = "$ICINGAWEB2_MODULE_GRAFANA_PROTOCOL"
timerangeAll = "$ICINGAWEB2_MODULE_GRAFANA_TIMERANGE"
defaultdashboard = "icinga2-default"
defaultdashboarduid = "1"
defaultdashboardpanelid = "1"
defaultorgid = "1"
shadows = "0"
theme = "light"
datasource = "influxdb"
accessmode = "indirectproxy"
debug = "0"
authentication = "anon"
indirectproxyrefresh = "yes"
height = "280"
width = "640"
enableLink = "no"
EOF

else

    # Disable Icinga Web 2 module Grafana.
    echo "Entrypoint: Disable Icinga Web 2 module grafana."
    icingacli module disable grafana
fi
