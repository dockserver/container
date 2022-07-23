#!/command/with-contenv bash
# shellcheck shell=bash
#####################################
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
# shellcheck disable=SC2002
# shellcheck disable=SC2006
## FUNCTIONS SOURCECONFIG ##
#########################################
# From here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################
source /system/mount/mount.env
#SETTINGS
CONFIG=/app/rclone/rclone.conf
ENVA=/system/mount/mount.env
TMPENV=/tmp/mount.env
GDSAMIN=4
ARRAY=$(ls -A ${JSONDIR} | wc -l )

#SCRIPTS
SDISCORD=/app/discord/discord.sh

#FOLDER
REMOTE=/mnt/unionfs
JSONDIR=/system/mount/keys
JSONUSED=/system/mount/.keys/.usedkeys
SMOUNT=/app/mount
FDISCORD=/app/discord
LFOLDER=/app/language/mount

#LOG
MLOG=/system/mount/logs/rclone-union.log
RLOG=/system/mount/logs/vfs-refresh.log
CLOG=/system/mount/logs/vfs-clean.log
DLOG=/tmp/discord.dead

#########################################
# From here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################
function log() {
   echo "[Mount] ${1}"
}

function checkban() {
if [[ `cat "${MLOG}" | wc -l` -gt 0 ]]; then
   tail -n 20 "${MLOG}" | grep --line-buffered 'downloadQuotaExceeded' | while read ;do
       if [ $? = 0 ]; then
          if [[ ! ${DISCORD_SEND} != "null" ]]; then
             discord
          else
             log "${startuphitlimit}"
          fi
          if [[ ${ARRAY} != 0 ]]; then
             rotate && log "${startuprotate}"
          fi
       fi
   done
fi
}

function rotate() {
[[ -f "/system/mount/.keys/lastkey" ]] && \
   $(which rm) -rf /system/mount/.keys/lastkey
[[ ! -d "/system/mount/.keys" ]] && \
   $(which mkdir) -p /system/mount/.keys/ && \
   $(which chown) -cR 1000:1000 /system/mount/.keys/ &>/dev/null
[[ -d "/system/mount/.keys" ]] && \
   $(which chown) -cR 1000:1000 /system/mount/.keys/ &>/dev/null
if [[ "${ARRAY}" -eq "0" ]]; then
   log " NO KEYS FOUND "
else
   JSONUSED=/system/mount/.keys/.usedkeys
   if [[ ! -f "${JSONUSED}" ]];then
      ls | sed -e 's/\.json$//' | sort -u > ${JSONUSED}
   fi
   $(which cat) "${JSONUSED}" | head -n 1 | while IFS=$'|' read -ra KEY ; do
      IFS=$'\n'
      filter="$1"
      log "-->> We switch the ServiceKey to ${KEY} "
      mapfile -t mounts < <(eval rclone listremotes --config=${CONFIG} | grep "$filter" | sed -e 's/://g' | sed '/ADDITIONAL/d'  | sed '/downloads/d'  | sed '/crypt/d' | sed '/gdrive/d' | sed '/union/d' | sed '/remote/d' | sed '/GDSA/d')
      for remote in ${mounts[@]}; do
          $(which rclone) config update $remote service_account_file ${KEY}.json --config=${CONFIG}
          $(which rclone) config update $remote service_account_file_path $JSONDIR --config=${CONFIG}
      done
      $(which sed) -i 1d "${JSONUSED}" && break
   done
   NEXTKEY=$($(which cat) ${JSONUSED} | head -n 1)
   log "-->> Rotate to next ServiceKey done || MountKey is now ${NEXTKEY} "
   $(which cp) -r /app/rclone/rclone.conf /root/.config/rclone/ && sleep 5 || exit 1
   log "-->> Next possible ServiceKey is ${KEY} "
   if [[ -f "/tmp/rclone.sh" ]]; then
      $(which screen) -S rclonerc -X quit
      $(which fusermount) -uzq /mnt/unionfs
      $(which chmod) 755 /tmp/rclone.sh &>/dev/null
      $(which screen) -S rclonerc -dm bash -c "$(which bash) /tmp/rclone.sh";
   else
      rcmount
   fi
fi
}

function discord() {
   source /system/mount/mount.env
   DATE=$(date "+%Y-%m-%d")
   YEAR=$(date "+%Y")
   SOURCE='https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh'
   if [[ ${ARRAY} -gt 0 ]]; then
       MSG1=${startuphitlimit}
       MSG2=${startuprotate}
       MSGSEND="${MSG1} and ${MSG2}"
       $(which rm) -rf ${DLOG}
   else
       MSG1=${startuphitlimit}
       MSGSEND="${MSG1}"
   fi
   [[ ! -d "${FDISCORD}" ]] && \
      $(which mkdir) -p "${FDISCORD}"
   [[ ! -f "${SDISCORD}" ]] && \
      $(which curl) --silent -fsSL "${SOURCE}" -o "${SDISCORD}" && chmod 755 "${SDISCORD}"
   [[ ! -f "${DLOG}" ]] && \
      $(which bash) "${SDISCORD}" \
      --webhook-url=${DISCORD_WEBHOOK_URL} \
      --title "${DISCORD_EMBED_TITEL}" \
      --avatar "${DISCORD_ICON_OVERRIDE}" \
      --author "Dockerserver.io Bot" \
      --author-url "https://dockserver.io/" \
      --author-icon "https://dockserver.io/img/favicon.png" \
      --username "${DISCORD_NAME_OVERRIDE}" \
      --description "${MSGSEND}" \
      --thumbnail "https://www.freeiconspng.com/uploads/error-icon-4.png" \
      --footer "(c) ${YEAR} DockServer.io" \
      --footer-icon "https://www.freeiconspng.com/uploads/error-icon-4.png" \
      --timestamp > "${DLOG}"
}

function envrenew() {
   diff -q "$ENVA" "$TMPENV"
   if [ $? -gt 0 ]; then
      rckill && rcmount && $(which cp) -r "$ENVA" "$TMPENV"
    else
      echo "no changes" &>/dev/null
   fi
}

function lang() {
   LANGUAGE=${LANGUAGE}
   currenttime=$(date +%H:%M)
   if [[ ! -d "/app/language" ]]; then
      $(which git) config --global --add safe.directory /app/language
      $(which git) -C /app clone --quiet https://github.com/dockserver/language.git
   fi
   if [[ "$currenttime" > "23:59" ]] || [[ "$currenttime" < "00:01" ]]; then
      if [[ -d "/app/language" ]]; then
         $(which git) config --global --add safe.directory /app/language
         $(which git) -C "${LFOLDER}/" stash --quiet
         $(which git) -C "${LFOLDER}/" pull --quiet
         $(which cd) "${LFOLDER}/"
         $(which git) stash clear
      fi
   fi
   startupmount=$(grep -Po '"startup.mount": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuphitlimit=$(grep -Po '"startup.hitlimit": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuprotate=$(grep -Po '"startup.rotate": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startupnewchanges=$(grep -Po '"startup.newchanges": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuprcloneworks=$(grep -Po '"startup.rcloneworks": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
}

function rlog() {
  SIZE=$(du /system/mount/logs/ | cut -f 1)
  ## 200MB max size of file
  if [[ $SIZE -gt 200000 ]]; then
     $(which truncate) -s 0 /system/mount/logs/*.log &>/dev/null
  fi
}

function folderunmount() {
for fod in /mnt/* ;do
    basename "$fod" >/dev/null
    FOLDER="$(basename -- $fod)"
    IFS=- read -r <<< "$ACT"
    if ! ls -1p "$fod/" >/dev/null ; then
       $(which fusermount) -uzq /mnt/$FOLDER && log "unmounting $FOLDER" || log "failed to unmounting $FOLDER"
    fi
done
}

function rcmount() {
[[ -f "/tmp/rclone.sh" ]] && $(which rm) -f /tmp/rclone.sh
source /system/mount/mount.env
export MLOG=/system/mount/logs/rclone-union.log \
CONFIG=/app/rclone/rclone.conf

cat > /tmp/rclone.sh << EOF; $(echo)
#!/command/with-contenv bash
# shellcheck shell=bash
# auto generated

## remove test file
[[ -f "/tmp/rclone.running" ]] && $(which rm) -f /tmp/rclone.running

$(which fusermount) -uzq /mnt/unionfs

#####
## start rclone mount
$(which rclone) mount remote: /mnt/remotes \\
--config=${CONFIG} \\
--log-file=${MLOG} \\
--log-level=${LOGLEVEL} \\
--uid=${PUID} \\
--gid=${PGID} \\
--umask=${UMASK} \\
--no-checksum \\
--allow-other \\
--allow-non-empty \\
--timeout=1h \\
--use-mmap \\
--ignore-errors \\
--poll-interval=${POLL_INTERVAL} \\
--user-agent=${UAGENT} \\
--cache-dir=${TMPRCLONE} \\
--tpslimit=${TPSLIMIT} \\
--tpslimit-burst=${TPSBURST} \\
--no-modtime \\
--no-seek \\
--drive-use-trash=${DRIVETRASH} \\
--drive-stop-on-upload-limit \\
--drive-server-side-across-configs \\
--drive-acknowledge-abuse \\
--drive-chunk-size=${DRIVE_CHUNK_SIZE} \\
--buffer-size=${BUFFER_SIZE} \\
--dir-cache-time=${DIR_CACHE_TIME} \\
--cache-info-age=${CACHE_INFO_AGE} \\
--vfs-cache-poll-interval=${VFS_CACHE_POLL_INTERVAL} \\
--vfs-cache-mode=${VFS_CACHE_MODE} \\
--vfs-cache-max-age=${VFS_CACHE_MAX_AGE} \\
--vfs-cache-max-size=${VFS_CACHE_MAX_SIZE} \\
--vfs-read-chunk-size-limit=${VFS_READ_CHUNK_SIZE_LIMIT} \\
--vfs-read-chunk-size=${VFS_READ_CHUNK_SIZE} \\
--rc --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD}

touch /tmp/rclone.running
###
EOF
## SET PERMISSIONS 
[[ -f "/tmp/rclone.sh" ]] && \
   $(which chmod) 755 /tmp/rclone.sh &>/dev/null
   $(which chmod) 700 /tmp/screens/S-root &>/dev/null
   $(which screen) -S rclonerc -dm bash -c "$(which bash) /tmp/rclone.sh";

## WAIT FOR RUNNING
for i in rclone; do
   if ! $(which pgrep) -x "$i" > /dev/null ; then
      sleep 5
   else
      break
   fi
done
}

function rcmergerfs() {
source /system/mount/mount.env
if [[ -d "${ADDITIONAL_MOUNT}" ]];then
   UFSPATH="/mnt/downloads=RW:${ADDITIONAL_MOUNT}=${ADDITIONAL_MOUNT_PERMISSION}:/mnt/remotes=NC"
else
   UFSPATH="/mnt/downloads=RW:/mnt/remotes=NC"
fi
###
MGFS="allow_other,rw,async_read=true,statfs_ignore=nc,use_ino,func.getattr=newest,category.action=all,category.create=mspmfs,cache.writeback=true,cache.symlinks=true,cache.files=auto-full,dropcacheonclose=true,nonempty,minfreespace=0,fsname=mergerfs"
## TO RUN JUST ONCE
if ! $(which pgrep) -x "mergerfs" > /dev/null; then
   $(which mergerfs) -o ${MGFS} ${UFSPATH} /mnt/unionfs &>/dev/null
else
   $(which mergerfs) -o ${MGFS} ${UFSPATH} /mnt/unionfs &>/dev/null
fi
}

function refreshVFS() {
source /system/mount/mount.env
log ">> run vfs refresh <<"
$(which rclone) rc vfs/refresh recursive=true \
--fast-list \
--rc-user=${RC_USER} \
--rc-pass=${RC_PASSWORD} \
--config=${CONFIG} \
--log-file=${RLOG} \
--log-level=${LOGLEVEL_RC} &>/dev/null
}

function rckill() {
source /system/mount/mount.env
log ">> kill it with fire <<"
## GET NAME TO KILL ##
for killscreen in `screen -ls | grep Detached | cut -d. -f2 | awk '{print $1}'` ; do
    log "we kill now $killscreen" && \
    $(which screen) -S $killscreen -X quit
done
folderunmount
}

function rcclean() {
source /system/mount/mount.env
log ">> run fs cache clear <<"
$(which rclone) rc fscache/clear \
--fast-list \
--rc-user=${RC_USER} \
--rc-pass=${RC_PASSWORD} \
--config=${CONFIG} \
--log-file=${CLOG} \
--log-level=${LOGLEVEL_RC}

}

function rcstats() {
# NOTE LATER
source /system/mount/mount.env
log ">> get rclone stats <<"
$(which rclone) rc core/stats \
--rc-user=${RC_USER} \
--rc-pass=${RC_PASSWORD} \
--config=${CONFIG}

}

function drivecheck() {
   if [ "$(ls -1p /mnt/unionfs)" ] && [ "$(ls -1p /mnt/remotes)" ]; then
      rcclean && refreshVFS
   fi
}

function testrun() {
## force a start sleeping to fetch all options 
  rlog && sleep 10
## FINAL LOOP
while true; do
   source /system/mount/mount.env
   if [ "$(ls -1p /mnt/remotes)" ] && [ "$(ls -1p /mnt/unionfs)" ]; then
      log "${startuprcloneworks}" && sleep 360
   else
      rckill && rcmount && rcmergerfs && rcclean
   fi
   rlog && envrenew && lang && checkban && sleep 360
done
}

#########################################
# Till here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################
     ### DO NOT MAKE ANY CHANGES ###
##  IF YOU DON'T KNOW WHAT YOU'RE DOING ##
##########################################
