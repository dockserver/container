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
APPBRANCH="master"
APPLINK="https://api.github.com/repos/zSeriesGuy/Tautulli"
NEWVERSION=$(curl -u $USERNAME:$TOKEN -sX GET "https://api.github.com/repos/zSeriesGuy/Tautulli/releases/latest" | jq -r '. | .tag_name')
NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

DESCRIPTION="$(curl -u $USERNAME:$TOKEN -sX GET "$APPLINK" | jq -r '.description')"
HEADLINE="$(cat ./.templates/headline.txt)"

##BASEIMAGE="ghcr.io/dockserver/docker-alpine:latest"
BASEIMAGE="ghcr.io/linuxserver/baseimage-alpine:3.15"

BUILDDATE="$(date +%Y-%m-%d)"
PICTURE="./images/$APP.png"

UPCOMMAND="apk --quiet --no-cache --no-progress update && \\
     apk --quiet --no-cache --no-progress upgrade"

INSTCOMMAND="apk add -U --update --no-cache"
PACKAGES="curl tar jq py3-openssl py3-setuptools python3 git"
VIRTUEL="--virtual=build-dependencies g++ gcc make py3-pip python3-dev"
PIPPACKAGES="python3 -m pip install --upgrade pip && \\
     pip3 install --no-cache-dir -U mock tzlocal plexapi cherrypy pycryptodomex"

CLEANUP="apk del --purge build-dependencies && \\
     apk del --quiet --clean-protected --no-progress && \\
     rm -f /var/cache/apk/*"

APPFOLDER="./$FOLDER/$APP"
PORT="EXPOSE 8181"
VOLUMEN="VOLUME /config"

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
FROM '"${BASEIMAGE}"'
LABEL org.opencontainers.image.source="'"https://github.com/dockserver/container"'"

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION="'"${NEWVERSION}"'"
ARG BRANCH="'"${APPBRANCH}"'"

ENV TAUTULLI_DOCKER=True

RUN \
   echo "'"**** update packages ****"'" && \
     '"${UPCOMMAND}"' && \
   echo "'"**** install virtual packages ****"'" && \
     '"${INSTCOMMAND}"' '"${VIRTUEL}"' && \
   echo "'"**** install build packages ****"'" && \
     '"${INSTCOMMAND}"' '"${PACKAGES}"' && \
   echo "'"**** install pip packages ****"'" && \
     '"${PIPPACKAGES}"' && \
   echo "'"**** install app ****"'" && \
     mkdir -p /app/tautulli && \
     curl -fsSL "'"https://github.com/zSeriesGuy/Tautulli/archive/v"'${VERSION}'".tar.gz"'" | tar xzf - -C /app/tautulli --strip-components=1 && \
   echo -e "'"v${NEWVERSION}"'" > /app/tautulli/version.txt && \
   echo -e "'"${APPBRANCH}"'" > /app/tautulli/branch.txt && \
   echo "'"*** cleanup system ****"'" && \
     '"${CLEANUP}"'

COPY '"${APPFOLDER}"'/root/ /

'"${PORT}"'

'"${VOLUMEN}"'
##EOF' > ./$FOLDER/$APP/Dockerfile
