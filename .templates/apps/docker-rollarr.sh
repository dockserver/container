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

APPLINK="https://github.com/TheHumanRobot/Rollarr"

NEWVERSION=$(curl -sX GET "https://registry.hub.docker.com/v1/repositories/library/ubuntu/tags" \
   | jq --raw-output '.[] | select(.name | contains(".")) | .name' \
   | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n1)
NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"
DESCRIPTION="This is the new and improved Automatic Pre-roll script with a GUI for Plex now called Rollarr!"

BASEIMAGE="ubuntu"

ENCOPY="ENV LANG=C.UTF-8 \\
    TZ=UTC \\
    PUID=1000 \\
    PGID=1000 \\
    DEBIAN_FRONTEND=noninteractive \\
    GPG_KEY=A035C8C19219BA821ECEA86B64E628F8D684696D \\
    PYTHON_VERSION=3.10.1 \\
    PYTHON_PIP_VERSION=21.2.4 \\
    PYTHON_SETUPTOOLS_VERSION=57.5.0 \\
    PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/3cb8888cc2869620f57d5d2da64da38f516078c7/public/get-pip.py \\
    PYTHON_GET_PIP_SHA256=c518250e91a70d7b20cceb15272209a4ded2a0c263ae5776f129e0d9b5674309 \\
    PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

APPFOLDER="./$FOLDER/$APP"
PICTURE="./images/$APP.png"
APPFOLDER="./$FOLDER/$APP"
PORT="EXPOSE 3100"

COM="CMD [ bash ]"
ADDRUN="RUN \\
    chmod 755 /rollarr/* && \\
    ./rollarr/install.sh && \\
    rm -rf /rollarr/install.sh && \\
    pip install -r /rollarr/requirements.txt && \\
    ln -s /rollarr/crontab /crontab 

RUN /usr/bin/crontab /crontab"

FINALCMD="CMD [ ./rollarr/run.sh ]"

### RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${NEWVERSION}'",
   "baseimage": "'${BASEIMAGE}'",
   "description": "'${DESCRIPTION}'",
   "body": "Upgrading '${APP}' to '${NEWVERSION}'",
   "user": "github-actions[bot]"
}' > "./$FOLDER/$APP/release.json"

### DOCKER BUILD ###
### GENERATE Dockerfile based on release.json

echo '## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
'"${HEADLINE}"'
FROM '"${BASEIMAGE}"':'"${NEWVERSION}"'

LABEL org.opencontainers.image.source="'"https://github.com/dockserver/container"'"

ARG TARGETPLATFORM
ARG BUILDPLATFORM

'"${ENCOPY}"'

'"${COM}"'

COPY '"${APPFOLDER}"'/root/ /

'"${ADDRUN}"'

'"${PORT}"'

'"${FINALCMD}"'
##EOF' > ./$FOLDER/$APP/Dockerfile
