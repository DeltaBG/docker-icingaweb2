# Dockerfile for deltabg_icingaweb2
# https://git.maniaci.net/DeltaBG/docker-icingaweb2

FROM ubuntu:focal

VOLUME /etc/icingaweb2

# Update system and install requirements
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apt-transport-https curl wget gnupg git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Icingaweb2
RUN export DEBIAN_FRONTEND=noninteractive \
    && curl -s https://packages.icinga.com/icinga.key | apt-key add - \
    && echo "deb https://packages.icinga.com/ubuntu icinga-focal main" > /etc/apt/sources.list.d/icinga.list \
    && echo "deb-src https://packages.icinga.com/ubuntu icinga-focal main" >> /etc/apt/sources.list.d/icinga.list \
    && apt-get update \
    && apt-get -y install \
        icingaweb2 \
        libapache2-mod-php \
        icingacli \
        mysql-client \
        php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-gmp php7.4-intl \
        php7.4-json php7.4-ldap php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline \
        php7.4-soap php7.4-xml \
        icinga-php-common icinga-php-library icinga-php-thirdparty \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Copy original configs in /etc/icingaweb2.dist/
    && cp -a /etc/icingaweb2 /etc/icingaweb2.dist

# Copy patches directory
ADD patches/ /patches/

# Install additional Icingaweb2 modules
RUN mkdir -p /usr/local/share/icingaweb2/modules \
    # Icinga Web 2 module Director
    && mkdir -p /usr/local/share/icingaweb2/modules/director \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-director/archive/v1.9.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/director --exclude=.gitignore -f - \
    && patch /usr/local/share/icingaweb2/modules/director/library/Director/IcingaConfig/IcingaConfigHelper.php \
    /patches/IcingaConfigHelper.php.patch \
    && patch /usr/local/share/icingaweb2/modules/director/library/Director/Data/PropertiesFilter/ArrayCustomVariablesFilter.php \
    /patches/ArrayCustomVariablesFilter.php.patch \
    # Icinga Web 2 module Graphite
    && mkdir -p /usr/local/share/icingaweb2/modules/graphite \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-graphite/archive/v1.1.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/graphite -f - \
    # Icinga Web 2 module Incubator
    && mkdir -p /usr/local/share/icingaweb2/modules/incubator \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-incubator/archive/v0.12.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/incubator -f - \
    && git clone https://github.com/Icinga/icingaweb2-module-x509.git /usr/local/share/icingaweb2/modules/x509 \
    && true

ADD content/ /

# Copy entrypoint.d, entrypoint.sh and healthcheck.sh scripts
ADD entrypoint.d/ /entrypoint.d/
COPY entrypoint.sh /
COPY healthcheck.sh /

HEALTHCHECK --interval=10s --timeout=10s --retries=9 --start-period=5s CMD /healthcheck.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
