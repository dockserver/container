#!/bin/bash
####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE      #
# NO CUSTOMIZING IS ALLOWED         #
# NO REBRANDING IS ALLOWED          #
# NO CODE MIRRORING IS ALLOWED      #
#####################################
# shellcheck disable=SC2086
# shellcheck disable=SC2046

FOLDER=$1
APP=$2
USERNAME=$3
TOKEN=$4

### APP SETTINGS ###

APPLINK="https://api.github.com/repos/spotweb/spotweb"
NEWVERSION=$(curl -u $USERNAME:$TOKEN -sX GET "https://api.github.com/repos/spotweb/spotweb/releases/latest"| jq --raw-output '.tag_name')
NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"
DESCRIPTION="$(curl -u $USERNAME:$TOKEN -sX GET "$APPLINK" | jq -r '.description')"
BASEIMAGE="ubuntu:latest"

### APP SETTINGS
APTOINSTALL="apache2 php8.0 php8.0-curl php8.0-gd php8.0-gmp php8.0-mysql php8.0-pgsql php8.0-xml php8.0-xmlrpc php8.0-mbstring php8.0-zip tar curl git-core cron wget jq locales"

INSTALL="apt-get -q update && \\
    apt -qy install software-properties-common && \\
    add-apt-repository ppa:ondrej/php && \\
    apt-get -qy dist-upgrade"

SETMOD="a2enmod headers && \\
    locale-gen --no-purge en_US.UTF-8"

CLEANUP="apt-get -yqq autoremove && \\
    apt-get -yqq clean && \\
    rm -rf /var/lib/apt/lists/* && \\
    rm -r /var/www/html && \\
    rm -rf /tmp/"

SETPERM="chmod -R 775 /var/www/spotweb && \\
    chown -R www-data:www-data /var/www/spotweb"

APPFOLDER="./$FOLDER/$APP"
PORT="EXPOSE 80"
VOLUMEN="VOLUME /config"
SETENTRY="RUN chmod u+x /entrypoint.sh"

### RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${NEWVERSION}'",
   "baseimage": "'${BASEIMAGE}'",
   "description": "'${DESCRIPTION}'",
   "body": "Upgrading '${APP}' to '${NEWVERSION}'",
   "user": "dockserver[bot]"
}' > "./$FOLDER/$APP/release.json"

echo '## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
FROM '"${BASEIMAGE}"'
LABEL org.opencontainers.image.source="'"https://github.com/dockserver/container"'"

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG VERSION="'"${NEWVERSION}"'"
ARG BRANCH="'"${APPBRANCH}"'"

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm"

RUN echo "'"force-unsafe-io"'" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "'"Acquire::http {No-Cache=True;};"'" > /etc/apt/apt.conf.d/no-cache && \
    '"${INSTALL}"' && \
    apt-get install -qy '"${APTOINSTALL}"' && \
    '"${SETMOD}"' && \
    '"${CLEANUP}"' && \
    mkdir -p /var/www/spotweb && \
    curl -fsSL "'"https://github.com/spotweb/spotweb/archive/refs/tags/"'${VERSION}'".tar.gz"'" | tar xzf - -C /var/www/spotweb --strip-components=1 && \
    '"${SETPERM}"'

COPY '"${APPFOLDER}"'/root/ /

'"${SETENTRY}"'
'"${PORT}"'
'"${VOLUMEN}"'

ENTRYPOINT ["/entrypoint.sh"]
##EOF' > ./$FOLDER/$APP/Dockerfile
