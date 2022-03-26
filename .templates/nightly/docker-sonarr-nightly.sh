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

### NIGHTLY HACK

APPNIGHTLY=$(echo $APP | sed "s#-nightly##g" )
if [[ $FOLDER == "nightly" ]]; then
   FOLDERNIGHTLY=apps
fi

### APP SETTINGS ###

APPBRANCH="develop"
APPLINK="https://api.github.com/repos/sonarr/sonarr"
NEWVERSION=$(curl -sX GET "https://services.sonarr.tv/v1/download/${APPBRANCH}?version=3" | jq --raw-output '.version')
NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"
DESCRIPTION="$(curl -u $USERNAME:$TOKEN -sX GET "$APPLINK" | jq -r '.description')"
BASEIMAGE="ghcr.io/dockserver/docker-alpine:latest"

INSTCOMMAND="apk add -U --update --no-cache"
PACKAGES="--repository http://dl-cdn.alpinelinux.org/alpine/edge/main jq openssl curl wget tar mediainfo sqlite-libs tinyxml2"
APPSPEC="--repository http://dl-cdn.alpinelinux.org/alpine/edge/testing mono"
CLEANUP="rm -rf /app/sonarr/bin/Sonarr.Update"

PICTURE="./images/$APP.png"
APPFOLDER="./$FOLDERNIGHTLY/$APPNIGHTLY"
PORT="EXPOSE 8989"
VOLUMEN="VOLUME /config"

### RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${NEWVERSION}'",
   "appbranch": "'${APPBRANCH}'",
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

RUN \
  echo "'"**** install build packages ****"'" && \
    '"${INSTCOMMAND}"' \
    '"${PACKAGES}"' && \
  echo "'"**** install app packages ****"'" && \
    '"${INSTCOMMAND}"' \
    '"${APPSPEC}"' && \
  echo "'"**** install '"${APP}"' ****"'" && \
    mkdir -p /app/sonarr/bin && \
    curl -fsSL "'"https://download.sonarr.tv/v3/"'${BRANCH}'"/"'${VERSION}'"/Sonarr."'${BRANCH}'"."'${VERSION}'".linux.tar.gz"'" | tar xzf - -C /app/sonarr/bin --strip-components=1 && \
  echo -e "'"UpdateMethod=docker\nBranch="'${BRANCH}'"\nPackageVersion="'${VERSION}'"\nPackageAuthor=[dockserver.io](https://dockserver.io)"'" > /app/sonarr/package_info && \
    echo -e "'"3.15"'" > /etc/alpine-release && \
  echo "'"**** cleanup ****"'" && \
    '"${CLEANUP}"'

COPY --chown=abc '"${APPFOLDER}"'/root/ /

'"${PORT}"'

'"${VOLUMEN}"'
##EOF' > ./$FOLDER/$APP/Dockerfile
