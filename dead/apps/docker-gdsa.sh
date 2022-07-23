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

NEWVERSION=$(curl -s "https://registry.hub.docker.com/v1/repositories/google/cloud-sdk/tags" \
 | jq --raw-output '.[] | select(.name | contains("-alpine")) | .name' \
 | tail -n1)
NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"
DESCRIPTION="Docker for Creating GDSA keys"
HEADLINE="$(cat ./.templates/headline.txt)"

BASEIMAGE="gcr.io/google.com/cloudsdktool/cloud-sdk"
PICTURE="./images/$APP.png"
APPFOLDER="./$FOLDER/$APP"
UPCOMMAND="apk --quiet --no-cache --no-progress update && \\
  apk --quiet --no-cache --no-progress upgrade"
INSTCOMMAND="apk add -U --update --no-cache"
PACKAGES="bash curl shadow musl findutils coreutils ca-certificates musl"
CLEANUP="apk del --quiet --clean-protected --no-progress && \\
  rm -f /var/cache/apk/*"

### RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${NEWVERSION}'",
   "baseimage": "'${BASEIMAGE}'",
   "description": "'${DESCRIPTION}'",
   "body": "Upgrading '${APP}' to '${NEWVERSION}'",
   "user": "dockserver-actions[bot]"
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
ARG VERSION="'"${NEWVERSION}"'"

RUN \
  echo "'"**** update packages ****"'" && \
    '"${UPCOMMAND}"' && \
  echo "'"**** install build packages ****"'" && \
    '"${INSTCOMMAND}"' '"${PACKAGES}"' && \
  echo "'"*** cleanup system ****"'" && \
    '"${CLEANUP}"'

COPY '"${APPFOLDER}"'/root/ /

ENTRYPOINT ["'"/bin/bash"'", "'"/gdsastart.sh"'"]
##EOF' > ./$FOLDER/$APP/Dockerfile
