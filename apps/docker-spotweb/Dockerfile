## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
FROM ubuntu:latest
LABEL org.opencontainers.image.source="https://github.com/dockserver/container"

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG VERSION="1.5.4"
ARG BRANCH=""

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm"

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt -qy install software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy apache2 php8.0 php8.0-curl php8.0-gd php8.0-gmp php8.0-mysql php8.0-pgsql php8.0-xml php8.0-xmlrpc php8.0-mbstring php8.0-zip tar curl git-core cron wget jq locales && \
    a2enmod headers && \
    locale-gen --no-purge en_US.UTF-8 && \
    apt-get -yqq autoremove && \
    apt-get -yqq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -r /var/www/html && \
    rm -rf /tmp/ && \
    mkdir -p /var/www/spotweb && \
    curl -fsSL "https://github.com/spotweb/spotweb/archive/refs/tags/${VERSION}.tar.gz" | tar xzf - -C /var/www/spotweb --strip-components=1 && \
    chmod -R 775 /var/www/spotweb && \
    chown -R www-data:www-data /var/www/spotweb

COPY ./apps/docker-spotweb/root/ /

RUN chmod u+x /entrypoint.sh
EXPOSE 80
VOLUME /config

ENTRYPOINT ["/entrypoint.sh"]
##EOF
