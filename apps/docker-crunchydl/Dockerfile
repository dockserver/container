## This file is automatically generated (based on release.json)
##
## Do not changes any lines here
##
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
FROM alpine:latest AS build
LABEL org.opencontainers.image.source="https://github.com/dockserver/container"

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION=null

RUN apk --quiet --no-cache --no-progress update && \
    apk --quiet --no-cache --no-progress upgrade && \
    rm -rf /app && \
    mkdir -p /app && \
    apk add -U --update --no-cache --no-progress \
      p7zip bash ca-certificates shadow musl \
      findutils linux-headers coreutils apk-tools busybox && \
    wget https://github.com/dockserver/multi-downloader-nx/releases/download/$VERSION/multi-downloader-nx-ubuntu-cli.7z -O /app/crunchy.7z && \
    cd /app && \
    7z e crunchy.7z && \
    rm -rf \
       /app/crunchy.7z \
       /app/multi-downloader-nx-ubuntu64-cli \
       /app/config/cli-defaults.yml

FROM debian:bullseye-slim

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends ffmpeg mkvtoolnix && \
     apt-get autoremove -y && apt-get clean -y && \
     rm -rf /var/lib/apt/lists/*

COPY --from=build /app/* ./

VOLUME /config
VOLUME /videos
ENTRYPOINT ["./aniDL"]
##EOF
