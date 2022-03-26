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

APPLINK="https://api.github.com/repos/haproxy/haproxy"
NEWVERSION=$(curl -sX GET "https://registry.hub.docker.com/v1/repositories/library/haproxy/tags" \
  | jq -r '.[] | select(.name| contains("-alpine3.15")) | .name' \
  | sort -t "." -k1,1n -k3,2n -k4,4n | tail -n1)
#NEWVERSION="${NEWVERSION#*v}"
#NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"
DESCRIPTION="$(curl -u $USERNAME:$TOKEN -sX GET "$APPLINK" | jq -r '.description')"
BASEIMAGE="haproxy"

PICTURE="./images/$APP.png"
APPFOLDER="./$FOLDER/$APP"
PORT="EXPOSE 2375"

FILES="haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg"

ENVIROMENTS="ENV ALLOW_RESTARTS=0 \\
    AUTH=0 \\
    BUILD=0 \\
    COMMIT=0 \\
    CONFIGS=0 \\
    CONTAINERS=0 \\
    DISTRIBUTION=0 \\
    EVENTS=1 \\
    EXEC=0 \\
    GRPC=0 \\
    IMAGES=0 \\
    INFO=0 \\
    LOG_LEVEL=info \\
    NETWORKS=0 \\
    NODES=0 \\
    PING=1 \\
    PLUGINS=0 \\
    POST=0 \\
    SECRETS=0 \\
    SERVICES=0 \\
    SESSION=0 \\
    SOCKET_PATH=/var/run/docker.sock \\
    SWARM=0 \\
    SYSTEM=0 \\
    TASKS=0 \\
    VERSION=1 \\
    VOLUMES=0"

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

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION="'"${NEWVERSION}"'"

'"${ENVIROMENTS}"'

'"${PORT}"'

COPY '"${APPFOLDER}"'/root/'"${FILES}"'
##EOF' > ./$FOLDER/$APP/Dockerfile
