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

DESCRIPTION="Docker Container for crunchyroll downloading Emby"
BASEIMAGE="node:17-bullseye-slim"
INSTCOMMAND="apt-get install"
UPTCOMMAND="apt-get update -y && apt-get upgrade -y"

CLEANUP="apt-get autoremove -yqq && apt-get clean -yqq && \\
     rm -rf /var/lib/apt/lists/*"

PULLFILE="git -c advice.detachedHead=false clone --depth 1 --branch ${VERSION} \
        https://github.com/anidl/multi-downloader-nx.git && \
    cd /multi-downloader-nx && \
    npm ci && \
    npm run build-linux64 && \
    BUILD=lib/_builds/multi-downloader-nx-${VERSION}-linux64 &&  \
    mkdir /build && \
    cp $BUILD/aniDL /build && \
    cp -r $BUILD/config /build"

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
ARG VERSION="'"${NEWVERSION}"'"

RUN '"${UPTCOMMAND}"' && \
    '"${INSTCOMMAND}"' -y --no-install-recommends ca-certificates p7zip-full git && \
    '"${CLEANUP}"' && \
    git -c advice.detachedHead=false clone --depth 1 --branch ${VERSION} \
        https://github.com/anidl/multi-downloader-nx.git && \
    cd /multi-downloader-nx && \
    npm ci && \
    npm run build-linux64 && \
    BUILD=lib/_builds/multi-downloader-nx-${VERSION}-linux64 &&  \
    mkdir /build && \
    cp $BUILD/aniDL /build && \
    cp -r $BUILD/config /build

FROM debian:bullseye-slim

RUN '"${UPTCOMMAND}"' && \
    '"${INSTCOMMAND}"' -y --no-install-recommends ffmpeg mkvtoolnix && \
     '"${CLEANUP}"'

COPY --from=build build/* ./

VOLUME /config
VOLUME /videos

COPY '"${APPFOLDER}"'/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["'"/bin/bash"'", "'"/entrypoint.sh"'"]
##EOF' > ./$FOLDER/$APP/Dockerfile

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
