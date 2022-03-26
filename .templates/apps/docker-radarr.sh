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
APPLINK="https://api.github.com/repos/radarr/radarr"
NEWVERSION=$(curl -sX GET "https://radarr.servarr.com/v1/update/${APPBRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')
NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"

DESCRIPTION="$(curl -u $USERNAME:$TOKEN -sX GET "$APPLINK" | jq -r '.description')"
BASEIMAGE="ghcr.io/dockserver/docker-alpine:latest"

INSTCOMMAND="apk add -U --update --no-cache"
PACKAGES="--repository http://dl-cdn.alpinelinux.org/alpine/edge/main jq openssl curl icu-libs wget tar sqlite-libs mediainfo"
APPSPEC="--repository http://dl-cdn.alpinelinux.org/alpine/edge/main tinyxml2"
APPSPEC2="--repository http://dl-cdn.alpinelinux.org/alpine/edge/community libmediainfo "
CLEANUP="rm -rf /app/radarr/bin/Radarr.Update"
PICTURE="./images/$APP.png"

APPFOLDER="./$FOLDER/$APP"
PORT="EXPOSE 7878"
VOLUMEN="VOLUME /config"

### RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${NEWVERSION}'",
   "appbranch": "'${APPBRANCH}'",
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

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION="'"${NEWVERSION}"'"
ARG BRANCH="'"${APPBRANCH}"'"

ENV XDG_CONFIG_HOME="'"/config/xdg"'"

RUN  \
  echo "'"**** install packages ****"'" && \
    '"${INSTCOMMAND}"' '"${PACKAGES}"' && \
    '"${INSTCOMMAND}"' '"${APPSPEC}"' && \
    '"${INSTCOMMAND}"' '"${APPSPEC2}"' && \
  echo "'"**** install '"${APP}"' ****"'" && \
    mkdir -p /app/radarr/bin && \
    curl -fsSL "'"https://radarr.servarr.com/v1/update/"'${BRANCH}'"/updatefile?version="'${VERSION}'"&os=linuxmusl&runtime=netcore&arch=x64"'" | tar xzf - -C /app/radarr/bin --strip-components=1 && \
  echo -e "'"UpdateMethod=docker\nBranch="'${BRANCH}'"\nPackageVersion="'${VERSION}'"\nPackageAuthor=[dockserver.io](https://dockserver.io)"'" > /app/radarr/package_info && \
  echo "'"**** cleanup ****"'" && \
    '"${CLEANUP}"'

COPY --chown=abc '"${APPFOLDER}"'/root/ /

'"${PORT}"'
'"${VOLUMEN}"'
##EOF' > ./$FOLDER/$APP/Dockerfile
