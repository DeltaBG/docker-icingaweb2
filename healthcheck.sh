#!/bin/bash
# Healthcheck for deltabg/icingaweb2

_APACHE_PID_FILE=/run/apache2/apache2.pid
_DIRECTOR_PID_FILE=/run/icingaweb2/director.pid

curl http://localhost/ > /dev/null 2>&1
_STATUS_CURL=$?

pgrep -F $_APACHE_PID_FILE > /dev/null 2>&1
_STATUS_APACHE=$?

# If Icinga Web 2 module Director is enable
if $ICINGAWEB2_MODULE_DIRECTOR; then

    pgrep -F $_DIRECTOR_PID_FILE > /dev/null 2>&1
    _STATUS_DIRECTOR=$?

else

    _STATUS_DIRECTOR=0

fi

if [ $_STATUS_CURL -eq 0 ] && [ $_STATUS_APACHE -eq 0 ] && [ $_STATUS_DIRECTOR -eq 0 ]; then
    # If curl test is OK and Apache2 process is runing
    exit 0
fi

exit 1
