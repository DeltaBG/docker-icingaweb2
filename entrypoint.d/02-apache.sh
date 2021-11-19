#!/bin/bash
# Entrypoint for deltabg/icingaweb2
# Apache

# Create SSL directory /etc/apache2/ssl.
echo "Entrypoint: Create SSL directory /etc/apache2/ssl."
mkdir -p /etc/apache2/ssl
chown -R root:root /etc/apache2/ssl

# If Icingaweb2 module Graphite is enable
if $ICINGAWEB2_SSL; then

    # Enable and setting up Apache HTTPS.
    echo "Entrypoint: Enable and setting up Apache HTTPS."
    a2enmod ssl
    ln -s ../sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

    if $ICINGAWEB2_SSL_LETSENCRYPT; then
        # Enable Apache mod_md.
        echo "Entrypoint: Enable Apache mod_md."
        a2enmod md
    fi

    cat <<EOF > /etc/apache2/sites-available/default-ssl.conf
<IfModule mod_ssl.c>

    <IfModule mod_md.c>
        MDomain $ICINGAWEB2_APACHE_SERVER_NAME
        ServerAdmin $ICINGAWEB2_APACHE_SERVER_ADMIN
        MDCertificateAgreement accepted
        MDPrivateKeys RSA 4096
    </IfModule>

    <VirtualHost *:443>
        Protocols h2 http/1.1

        ServerName $ICINGAWEB2_APACHE_SERVER_NAME
        ServerAdmin $ICINGAWEB2_APACHE_SERVER_ADMIN
        DocumentRoot /var/www/html

        ErrorLog \${APACHE_LOG_DIR}/ssl-error.log
        CustomLog \${APACHE_LOG_DIR}/ssl-access.log combined

        RewriteEngine on
        RewriteRule ^/$ /icingaweb2/ [R=301,L]

        SSLEngine on

        <IfModule mod_md.c>
        # Fallback of mod_md
        SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
        SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
        </IfModule>

        <IfModule !mod_md.c>
        SSLCertificateFile /etc/apache2/ssl/cert.pem
        SSLCertificateKeyFile /etc/apache2/ssl/privkey.pem
        SSLCertificateChainFile /etc/apache2/ssl/chain.pem
        </IfModule>

    </VirtualHost>
</IfModule>
EOF

fi

cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>

    ServerName $ICINGAWEB2_APACHE_SERVER_NAME
    ServerAdmin $ICINGAWEB2_APACHE_SERVER_ADMIN
    DocumentRoot /var/www/html

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    RewriteEngine on
    RewriteRule ^/$ /icingaweb2/ [R=301,L]

    <IfModule mod_ssl.c>
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI}
    </IfModule>

</VirtualHost>
EOF

if $ICINGAWEB2_SSL && $ICINGAWEB2_SSL_LETSENCRYPT; then

    # Start Apache 2 for 5 seconds to generate SSL.
    echo "Entrypoint: Start Apache 2 for 10 seconds to generate SSL."
    apache2ctl -k start
    sleep 10
    apache2ctl -k stop

fi
