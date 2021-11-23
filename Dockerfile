# Dockerfile for deltabg_icingaweb2
# https://git.maniaci.net/DeltaBG/docker-icingaweb2

FROM ubuntu:focal

VOLUME /etc/icingaweb2

# Update system and install requirements
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apt-transport-https curl wget gnupg \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Copy original configs in /etc/icingaweb2.dist/
    && cp -a /etc/icingaweb2 /etc/icingaweb2.dist

# Install additional Icingaweb2 modules
RUN mkdir -p /usr/local/share/icingaweb2/modules \
    # Icinga Web 2 module Director
    && mkdir -p /usr/local/share/icingaweb2/modules/director \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-director/archive/v1.8.1.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/director --exclude=.gitignore -f - \
    # Icinga Web 2 module Graphite
    && mkdir -p /usr/local/share/icingaweb2/modules/graphite \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-graphite/archive/v1.1.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/graphite -f - \
    # Icinga Web 2 module Incubator
    && mkdir -p /usr/local/share/icingaweb2/modules/incubator \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-incubator/archive/v0.6.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/incubator -f - \
    && true

ADD content/ /

# Copy entrypoint.d, entrypoint.sh and healthcheck.sh scripts
ADD entrypoint.d/ /entrypoint.d/
COPY entrypoint.sh /
COPY healthcheck.sh /

HEALTHCHECK --interval=10s --timeout=10s --retries=9 --start-period=5s CMD /healthcheck.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]