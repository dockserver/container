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
APPLINK="https://github.com/anidl/multi-downloader-nx"
NEWVERSION=$(curl -u $USERNAME:TOKEN -sX GET https://api.github.com/repos/anidl/multi-downloader-nx/releases/latest | jq --raw-output '. | .tag_name')
NEWVERSION="${NEWVERSION#*v}"
NEWVERSION="${NEWVERSION#*release-}"
NEWVERSION="${NEWVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"

PICTURE="./images/$APP.png"
APPFOLDER="./$FOLDER/$APP"

DESCRIPTION="Docker Container for crunchyroll download client"
BASEIMAGE="alpine:latest"
INSTCOMMAND="apt-get install"
UPTCOMMAND="apt-get update -y && apt-get upgrade -y"

CLEANUP="apt-get autoremove -yqq && apt-get clean -yqq && \\
     rm -rf /var/lib/apt/lists/*"

PULLFILE="RUN apk --quiet --no-cache --no-progress update && \\
    apk --quiet --no-cache --no-progress upgrade && \\
    rm -rf /app && \\
    mkdir -p /app && \\
    apk add -U --update --no-cache \
      p7zip bash ca-certificates shadow musl \
      findutils linux-headers coreutils apk-tools busybox && \\
    wget https://github.com/anidl/multi-downloader-nx/releases/download/$VERSION/multi-downloader-nx-ubuntu-cli.7z -O /app/crunchy.7z && \\
    cd /app && \\
    7z e crunchy.7z && \\
    rm -rf /app/crunchy.7z /app/multi-downloader-nx-ubuntu64-cli"

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
   "user": "dockserver-image[bot]"
}' > "./$FOLDER/$APP/release.json"

echo '## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
'"${HEADLINE}"'
FROM '"${BASEIMAGE}"' AS build
LABEL org.opencontainers.image.source="'"https://github.com/dockserver/container"'"

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION='"${NEWVERSION}"'

'"${PULLFILE}"'

FROM debian:bullseye-slim

RUN '"${UPTCOMMAND}"' && \
    '"${INSTCOMMAND}"' -y --no-install-recommends ffmpeg mkvtoolnix && \
     '"${CLEANUP}"'

COPY --from=build build/* ./

VOLUME /config
VOLUME /videos
ENTRYPOINT ["'"./aniDL"'"]
##EOF' > ./$FOLDER/$APP/Dockerfile


### FOR LOGIN ###
#  docker run -it --rm \
#    -v /opt/appdata/crunchy:/config:rw \
#    ghcr.io/dockserver/docker-crunchydl:latest\
#    --service crunchy --auth

### FOR DOWNLOADING ###
#  service|lang|serienid #
#  CHK=MUSS SETZT GESETZ WERDEN
#  $(which cat) "${CHK}" | head -n 1 | while IFS=$'|' read -ra SHOWLINK ; do
#    $(which echo) "**** downloading now ${SHOWLINK[1]} ****"
#      docker run -it --rm \
#      -v /opt/appdata/crunchy:/config:rw \
#      -v /mnt/unionfs/crunchy:/videos:rm \
#      ghcr.io/dockserver/docker-crunchydl:latest\
#      --service ${SHOWLINK[0]} \
#      --series ${SHOWLINK[2]} \
#      -q 0 --dlsubs all \
#      --dubLang ${SHOWLINK[1]} \
#      --filename ${showTitle}.${title}.S${season}E${episode}.WEBHD.${height} \
#      --force Y --mp4 --nocleanup --skipUpdate
#  done

#  $(which cat) "${CHK}" | head -n 1 | while IFS=$'|' read -ra SHOWLINK ; do
#  $(which echo) "**** downloading now ${SHOWLINK[1]} ****"
#     ./aniDL \
#     --username ${EMAIL}
#     --password ${PASSWORD} \
#     --new \
#     --service ${SHOWLINK[0]} \
#     --series ${SHOWLINK[2]} \
#     -q 0 --dlsubs all \
#     --dubLang ${SHOWLINK[1]} \
#     --filename=${showTitle}.${title}.S${season}E${episode}.WEBHD.${height} \
#    --force Y --mp4 --nocleanup --skipUpdate
