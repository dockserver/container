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

APPBRANCH="nightly"
APPLINK="https://api.github.com/repos/whisparr/whisparr"
NEWVERSION=$(curl -sX GET "https://whisparr.servarr.com/v1/update/${APPBRANCH}/changes?os=linuxmusl&runtime=netcore&arch=x64" | jq -r .[0].version)

NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"

##DESCRIPTION="$(curl -u $USERNAME:$TOKEN -sX GET "$APPLINK" | jq -r '.description')"
DESCRIPTION="Whisparr is an adult movie collection manager for Usenet and BitTorrent users."
BASEIMAGE="ghcr.io/linuxserver/baseimage-alpine"
ALPINEVERSION=$(curl -u $USERNAME:$TOKEN -sX GET "https://api.github.com/repos/linuxserver/docker-baseimage-alpine/releases/latest" | jq --raw-output '.tag_name')

INSTCOMMAND="apk add -U --update --no-cache"
PACKAGES="icu-libs sqlite-libs"
CLEANUP="rm -rf /app/whisparr/bin/Whisparr.Update"
PICTURE="./images/$APP.png"

APPFOLDER="./$FOLDER/$APP"
PORT="EXPOSE 6969"
VOLUMEN="VOLUME /config"

### RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${NEWVERSION}'",
   "appbranch": "'${APPBRANCH}'",
   "baseimage": "'${BASEIMAGE}'",
   "baseversion": "'${ALPINEVERSION}'",
   "description": "'${DESCRIPTION}'",
   "body": "Upgrading '${APP}' to '${NEWVERSION}'",
   "user": "dockserver image update[bot]"
}' > "./$FOLDER/$APP/release.json"

### DOCKER BUILD ###
### GENERATE Dockerfile based on release.json

echo '## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
'"${HEADLINE}"'
FROM '"${BASEIMAGE}"':'"${ALPINEVERSION}"'
LABEL org.opencontainers.image.source="'"https://github.com/dockserver/container"'"

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG VERSION='"${NEWVERSION}"'
ARG BRANCH='"${APPBRANCH}"'
ARG ALPINE_VERSION='"${ALPINEVERSION}"'

RUN \
  echo "'"**** install build packages ****"'" && \
    '"${INSTCOMMAND}"' '"${PACKAGES}"' && \
  echo "'"**** install '"${APP}"' ****"'" && \
    mkdir -p /app/whisparr/bin && \
    curl -fsSL "'"https://whisparr.servarr.com/v1/update/"'${BRANCH}'"/updatefile?version="'${VERSION}'"&os=linuxmusl&runtime=netcore&arch=x64"'" | tar xzf - -C /app/whisparr/bin --strip-components=1 && \
  echo -e "'"UpdateMethod=docker\nBranch="'${BRANCH}'"\nPackageVersion="'${VERSION}'"\nPackageAuthor=[dockserver.io](https://dockserver.io)"'" > /app/whisparr/package_info && \
  echo "'"**** cleanup ****"'" && \
    '"${CLEANUP}"'

COPY --chown=abc '"${APPFOLDER}"'/root/ /

'"${PORT}"'
'"${VOLUMEN}"'
##EOF' > ./$FOLDER/$APP/Dockerfile
