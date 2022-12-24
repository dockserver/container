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

APPLINK="https://api.github.com/repos/dockserver/dockserver"
BUILDVERSION=$(curl -sX GET "https://registry.hub.docker.com/v2/repositories/library/alpine/tags" \
   | jq -r 'select(.results != null) | .results[]["name"]' \
   | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n1)
BUILDVERSION="${BUILDVERSION#*v}"
BUILDVERSION="${BUILDVERSION#*release-}"
BUILDVERSION="${BUILDVERSION}"

BUILDIMAGE="alpine"
FINALIMAGE="ghcr.io/dockserver/docker-alpine-v3"
ALPINEVERSION="${BUILDVERSION}"

HEADLINE="$(cat ./.templates/headline.txt)"
PICTURE="./images/$APP.png"
APPFOLDER="./$FOLDER/$APP"

INSTCOMMAND="apk add -U --update --no-cache --quiet"
UPCOMMAND="apk --quiet --no-cache --no-progress update && \\
  apk --quiet --no-cache --no-progress upgrade"


CLEAN="apk del --purge --quiet"
VOLUMEN="VOLUME /system"
EPOINT="ENTRYPOINT /init"

## BUILDPACK
BUILDPACK="bash wget unzip git fuse libattr libstdc++ autoconf \\
      automake libtool gettext-dev attr-dev linux-headers make \\
      build-base libattr libstdc++ tar curl"

## MERGERFS
MGVERSION="$(curl -u $USERNAME:$TOKEN -sX GET "https://api.github.com/repos/trapexit/mergerfs/releases/latest" | jq --raw-output '.tag_name')"
MKFOLDER="mkdir -p /tmp/mergerfs"
MAKEMG="cd /tmp/mergerfs && make STATIC=1 LTO=1 && make install"

## RCLONE
RCINSTALL="wget -qO- https://rclone.org/install.sh | bash"
RCVERSION="$(curl -u $USERNAME:$TOKEN -sX GET "https://api.github.com/repos/rclone/rclone/releases/latest" | jq --raw-output '.tag_name')"

## S6-OVERLAY
S6_STAGE_VERSION="$(curl -u $USERNAME:$TOKEN -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | jq --raw-output '.tag_name')"

## FINAL IMAGE
FINALPACKAGES="bash jq musl findutils linux-headers apk-tools busybox coreutils procps shadow"

## ENDSTAGE
BUILDSTAGE="COPY --from=builder --chown=abc --chmod=755 /usr/local/bin/mergerfs /usr/local/bin/mergerfs
COPY --from=builder --chown=abc --chmod=755 /usr/local/bin/mergerfs-fusermount /usr/local/bin/mergerfs-fusermount
COPY --from=builder --chown=abc --chmod=755 /sbin/mount.mergerfs /sbin/mount.mergerfs
COPY --from=builder --chown=abc --chmod=755 /usr/bin/rclone /usr/local/bin/rclone"

CLEANUP="apk del --quiet --clean-protected --no-progress && \\
    rm -rf /var/cache/apk/* /tmp/*"

## S6 FIX
find ./$FOLDER/$APP/root/ -mindepth 1 -type f | while read rename; do
    sed -i 's|/usr/bin|/command|g' ${rename}
done

## RELEASE SETTINGS ###

echo '{
   "appname": "'${APP}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$FOLDER'/'$APP'",
   "newversion": "'${BUILDVERSION}'",
   "mergerfs": "'${MGVERSION}'",
   "rclone": "'${RCVERSION}'",
   "baseimage": "'${BUILDIMAGE}'",
   "buildimage": "'${BUILDIMAGE}'",
   "finalimage": "'${FINALIMAGE}'",
   "baseversion": "'${ALPINEVERSION}'",
   "s6stage": "'${S6_STAGE_VERSION}'",
   "description": "Docker '${APP}' with mergerfs version '${MGVERSION}' and rclone version '${RCVERSION}' include s6-overlay: '${S6_STAGE_VERSION}'",
   "body": "Upgrading '${APP}' to baseimage: '${BUILDIMAGE}':'${ALPINEVERSION}' with mergerfs: '${MGVERSION}' and rclone: '${RCVERSION}' include s6-overlay: '${S6_STAGE_VERSION}'",
   "user": "dockserver image update[bot]"
}' > "./$FOLDER/$APP/release.json"

### DOCKER BUILD ###
### GENERATE Dockerfile based on release.json

echo '## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
'"${HEADLINE}"'
FROM '"${BUILDIMAGE}"':'"${BUILDVERSION}"' as builder

LABEL org.opencontainers.image.source="'"https://github.com/dockserver/container"'"

### BUILD STAGE
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG MERGERFS_VERSION='"${MGVERSION}"'

RUN \
  echo "'"**** update packages ****"'" && \
    '"${UPCOMMAND}"' && \
  echo "'"**** install build packages ****"'" && \
    '"${INSTCOMMAND}"' '"${BUILDPACK}"' && \
  echo "'"**** install mergerfs ****"'" && \
    '"${MKFOLDER}"' && \
    curl -fsSL "'"https://github.com/trapexit/mergerfs/releases/download/"'${MERGERFS_VERSION}'"/mergerfs-"'${MERGERFS_VERSION}'".tar.gz"'" | tar xzf - -C /tmp/mergerfs --strip-components=1 && \
    '"${MAKEMG}"' && \
  echo "'"**** install rclone ****"'" && \
    '"${RCINSTALL}"' && \
  echo "'"*** cleanup build dependencies ****"'" && \
    '"${CLEAN}"' \
    '"${BUILDPACK}"' && \
  echo "'"*** cleanup build system ****"'" && \
    '"${CLEANUP}"'

FROM '"${FINALIMAGE}"':latest

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG BASE_VERSION='"${BUILDVERSION}"'
ARG ALPINE_VERSION='"${ALPINEVERSION}"'
ARG MERGERFS_VERSION='"${MGVERSION}"'
ARG RCLONE_VERSION='"${RCVERSION}"'

RUN \
  echo "'"**** update packages ****"'" && \
    '"${UPCOMMAND}"' && \
  echo "'"**** install build packages ****"'" && \
    '"${INSTCOMMAND}"' '"${FINALPACKAGES}"' && \
  echo "'"**** set alpine version ****"'" && \
    echo -e "'"${BUILDVERSION}"'" > /etc/alpine-release && \
  echo "'"*** cleanup system ****"'" && \
    '"${CLEANUP}"'

COPY --chown=abc --chmod=755 '"${APPFOLDER}"'/root/ /

'"${BUILDSTAGE}"'

'"${VOLUMEN}"'

'"${EPOINT}"'
##EOF' > ./$FOLDER/$APP/Dockerfile
