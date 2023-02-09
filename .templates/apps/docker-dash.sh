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

BASENEWVERSION=$(curl -sX GET "https://registry.hub.docker.com/v2/repositories/library/alpine/tags" \
   | jq -r 'select(.results != null) | .results[]["name"]' \
   | sort -t "." -k1,1n -k2,2n -k3,3n | grep "\." | tail -n1)
BASENEWVERSION="${BASENEWVERSION#*v}"
BASENEWVERSION="${BASENEWVERSION#*release-}"
BASENEWVERSION="${BASENEWVERSION}"

APPBRANCH="main"

APPLINK="https://api.github.com/repos/MauriceNino/dashdot"
NEWVERSION=$(curl -sX GET "https://api.github.com/repos/MauriceNino/dashdot/releases/latest" | jq --raw-output '.tag_name')

NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"
DESCRIPTION="$(curl -u $USERNAME:$TOKEN -sX GET "$APPLINK" | jq -r '.description')"
BASEIMAGE="alpine"

## FINALIMAGE
FINALIMAGE="node:18-alpine3.15"
APPFOLDER="./$FOLDER/$APP"

### RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${NEWVERSION}'",
   "baseimage": "'${BASEIMAGE}'",
   "baseversion": "'${BASENEWVERSION}'",
   "description": "'${DESCRIPTION}'",
   "body": "Upgrading '${APP}' to '${NEWVERSION}'",
   "user": "dockserver-image[bot]"
}' > "./$FOLDER/$APP/release.json"

### DOCKER BUILD ###
### GENERATE Dockerfile based on release.json

echo '## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
'"${HEADLINE}"'
FROM mauricenino/dashdot
LABEL org.opencontainers.image.source="'"https://github.com/dockserver/container"'"

ENV DASHDOT_OS_WIDGET_ENABLE="'"true"'" \
    DASHDOT_CPU_WIDGET_ENABLE="'"true"'" \
    DASHDOT_CPU_DATAPOINTS="'"20"'" \
    DASHDOT_CPU_POLL_INTERVAL="'"1000"'" \
    DASHDOT_RAM_WIDGET_ENABLE="'"true"'" \
    DASHDOT_RAM_POLL_INTERVAL="'"1000"'" \
    DASHDOT_STORAGE_WIDGET_ENABLE="'"true"'"

CMD ["'"yarn"'", "'"start"'"]
##EOF' > ./$FOLDER/$APP/Dockerfile
