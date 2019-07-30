#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will work
# if Magisk changes it's mount point in the future

MODDIR=${0%/*}

IMGDIR=/sbin/.core/img
UPDDIR=/data/adb/modules_update
id=com.piyushgarg.rclone

if [ -e ${UPDDIR}/${id}/rclone-wrapper.sh ]; then

    ln -sf ${UPDDIR}/${id}/rclone-wrapper.sh /sbin/rclone
    ln -sf ${UPDDIR}/${id}/fusermount-wrapper.sh /sbin/fusermount
    HOME=${UPDDIR}/${id}

elif [ -e ${IMGDIR}/${id}/rclone-wrapper.sh ]; then

    ln -sf ${IMGDIR}/${id}/rclone-wrapper.sh /sbin/rclone
    ln -sf ${IMGDIR}/${id}/fusermount-wrapper.sh /sbin/fusermount
    HOME=${IMGDIR}/${id}

else

    ln -sf ${MODDIR}/rclone-wrapper.sh /sbin/rclone
    ln -sf ${MODDIR}/fusermount-wrapper.sh /sbin/fusermount
    HOME=${MODDIR}

fi

#MODULE VARS
USER_CONFDIR=/sdcard/.rclone
USER_CONF=${USER_CONFDIR}/rclone.conf
CONFIGFILE=${HOME}/.config/rclone/rclone.conf
LOGFILE=${USER_CONFDIR}/rclone.log
LOGLEVEL=NOTICE
DATA_MEDIA=/data/media/0
RUNTIME_R=/mnt/runtime/read
RUNTIME_W=/mnt/runtime/write
RUNTIME_D=/mnt/runtime/default
BINDPOINT_R=${RUNTIME_R}/emulated/0/Cloud
BINDPOINT_W=${RUNTIME_W}/emulated/0/Cloud
BINDPOINT_D=${RUNTIME_D}/emulated/0/Cloud
SD_BINDPOINT=${BINDPOINT_D}
CLOUDROOTMOUNTPOINT=/mnt/cloud

#RCLONE PARAMETERS
DISABLE=0
BUFFERSIZE=0
CACHEMAXSIZE=1G
DIRCACHETIME=30m0s
ATTRTIMEOUT=30s
CACHEINFOAGE=1h0m0s
READAHEAD=128k
CACHEMODE=off
CACHE=${USER_CONFDIR}/.cache
CACHE_BACKEND=${USER_CONFDIR}/.cache-backend
HTTP_ADDR=127.0.0.1:38762
FTP_ADDR=127.0.0.1:38763
NETCHK_ADDR=google.com

if [[ -z ${INTERACTIVE} ]]; then

    INTERACTIVE=0

fi


if [[ ! -d ${HOME}/.config/rclone ]]; then

    mkdir -p ${HOME}/.config/rclone

fi

custom_params () {

    PARAMS="BUFFERSIZE CACHEMAXSIZE DIRCACHETIME ATTRTIMEOUT CACHEINFOAGE READAHEAD CACHEMODE DISABLE READONLY BINDSD BINDPOINT NETCHK_ADDR ADD_PARAMS"

    BAD_SYNTAX="(^\s*#|^\s*$|^\s*[a-z_][^[:space:]]*=[^;&\(\`]*$)"

    if [[ -e ${USER_CONFDIR}/.${remote}.param ]]; then

        echo "Found .${remote}.param"

        if ! [[ $(egrep -q -iv "${BAD_SYNTAX}" ${USER_CONFDIR}/.${remote}.param) ]]; then

            echo "loading .${remote}.param"

            for PARAM in ${PARAMS[@]}; do

                while read -r VAR; do

                    if [[ "$(echo "${VAR}" |grep -w "$PARAM")" ]]; then
                        echo "Importing ${VAR}"
                        VALUE="$(echo ${VAR} |cut -d '=' -f2)"

                        VALUE=\"${VALUE}\"

                        eval $(echo "${PARAM}""=""${VALUE}")

                    fi

                done < ${USER_CONFDIR}/.${remote}.param

            done

        else

            echo ".${remote}.param contains bad syntax"

        fi

    fi

}

remote=global
custom_params
unset remote
echo

NET_CHK() {

   ping -c 5 ${NETCHK_ADDR}

}

sd_unbind () {

    if [[ -z ${BINDPOINT} ]]; then

        UNBINDPOINT=${BINDPOINT_DEF}/${remote}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${BINDPOINT_R}/${remote}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${BINDPOINT_W}/${remote}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

    else 

        USER_BINDPOINT=${BINDPOINT}

        UNBINDPOINT=${RUNTIME_D}/emulated/0/${USER_BINDPOINT}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${RUNTIME_R}/emulated/0/${USER_BINDPOINT}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${RUNTIME_W}/emulated/0/${USER_BINDPOINT}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        fi

}

sd_binder () {

    if [[ -d ${RUNTIME_D} ]] && [[ ${BINDSD} = 1 ]] || [[ -e ${USER_CONFDIR}.bindsd ]]; then

        if [[ -z ${BINDPOINT} ]]; then 

            mkdir -p ${DATA_MEDIA}/Cloud/${remote}
            chown media_rw:media_rw ${DATA_MEDIA}/Cloud/$remote

            BINDPOINT=${BINDPOINT_D}/${remote}

            su -M -c mount --bind ${CLOUDROOTMOUNTPOINT}/${remote} ${BINDPOINT} >> /dev/null 2>&1

            BINDPOINT=${BINDPOINT_R}/${remote}

            if ! mount |grep -q ${BINDPOINT}; then

                su -M -c mount --bind ${CLOUDROOTMOUNTPOINT}/${remote} ${BINDPOINT} >> /dev/null 2>&1

            fi

            BINDPOINT=${BINDPOINT_W}/${remote}

            if ! mount |grep -q ${BINDPOINT}; then

            su -M -c mount --bind ${CLOUDROOTMOUNTPOINT}/${remote} ${BINDPOINT} >> /dev/null 2>&1

            fi

        else 

            mkdir ${DATA_MEDIA}/${BINDPOINT} >> /dev/null 2>&1
            chown media_rw:media_rw ${DATA_MEDIA}/${BINDPOINT}

            USER_BINDPOINT=${BINDPOINT}
            BINDPOINT=${RUNTIME_D}/emulated/0/${USER_BINDPOINT}

            su -M -c mount --bind ${CLOUDROOTMOUNTPOINT}/${remote} ${BINDPOINT} >> /dev/null 2>&1

            BINDPOINT=${RUNTIME_R}/emulated/0/${USER_BINDPOINT}

            if ! mount |grep -q ${BINDPOINT}; then

                su -M -c mount --bind ${CLOUDROOTMOUNTPOINT}/${remote} ${BINDPOINT} >> /dev/null 2>&1

            fi

            BINDPOINT=${RUNTIME_W}/emulated/0/${USER_BINDPOINT}

            if ! mount |grep -q ${BINDPOINT}; then

                su -M -c mount --bind ${CLOUDROOTMOUNTPOINT}/${remote} ${BINDPOINT} >> /dev/null 2>&1

            fi

        fi

    fi

    unset BINDPOINT

}

rclone_mount () {

    if [[ ${READONLY} = 1 ]]; then

        READONLY=" --read-only "

    else

        READONLY=" "

    fi

    if [[ -z ${ADD_PARAMS} ]]; then

        ADD_PARAMS=" "

    elif [[ ! -z ${ADD_PARAMS} ]]; then

        ADD_PARAMS=" ${ADD_PARAMS} "

    fi

    echo "[${remote}] available at: -> [${CLOUDROOTMOUNTPOINT}/${remote}]"

    mkdir -p ${CLOUDROOTMOUNTPOINT}/${remote}

    su -M -p -c nice -n 19 ionice -c 2 -n 7 $HOME/rclone mount ${remote}: ${CLOUDROOTMOUNTPOINT}/${remote} --config ${CONFIGFILE} --log-file ${LOGFILE} --log-level ${LOGLEVEL} --cache-dir ${CACHE} --cache-chunk-path ${CACHE_BACKEND} --cache-db-path ${CACHE_BACKEND} --cache-tmp-upload-path ${CACHE} --vfs-cache-mode ${CACHEMODE} --cache-chunk-no-memory --cache-chunk-size 1M --cache-chunk-total-size ${CACHEMAXSIZE} --cache-workers 1 --use-mmap --buffer-size ${BUFFERSIZE} --max-read-ahead ${READAHEAD} --dir-cache-time ${DIRCACHETIME} --attr-timeout ${ATTRTIMEOUT} --cache-info-age ${CACHEINFOAGE} --no-modtime --no-checksum --uid 0 --gid 1015 --allow-other --dir-perms 0775 --file-perms 0644 --umask 002 ${READONLY} ${ADD_PARAMS}--daemon & >> /dev/null 2>&1

    sleep 5

}

COUNT=0

if [[ ${INTERACTIVE} = 0 ]]; then

    until [[ $(getprop sys.boot_completed) = 1 ]] && [[ $(getprop dev.bootcomplete) = 1 ]] && [[ $(getprop service.bootanim.exit) = 1 ]] && [[ $(getprop init.svc.bootanim) = stopped ]] && [[ -e ${USER_CONF} ]] || [[ ${COUNT} -eq 240 ]]; do

        sleep 5
        ((++COUNT))

    done

fi

DECRYPT_CHK () {

    su -M -c ls sdcard |grep -q -w "Android"

}

sleep 5

if [[ ${COUNT} -eq 240 ]] || [[ ! -d /sdcard/Android ]]; then

    echo "Not decrypted"
    exit 0

fi

if [[ ! -d ${USER_CONFDIR} ]]; then 

    mkdir ${USER_CONFDIR}

fi

if [[ -e ${USER_CONFDIR}/.disable ]]; then 

    exit 0

fi

if [[ ! -d ${CLOUDROOTMOUNTPOINT} ]]; then

    mkdir -p ${CLOUDROOTMOUNTPOINT}
    chown root:sdcard_rw ${CLOUDROOTMOUNTPOINT}
    touch ${CLOUDROOTMOUNTPOINT}/.nomedia
    chown root:sdcard_rw ${CLOUDROOTMOUNTPOINT}/.nomedia
    chmod 0775 ${CLOUDROOTMOUNTPOINT}/.nomedia

fi

if [[ ! -e ${CLOUDROOTMOUNTPOINT}/.nomedia ]]; then

    touch ${CLOUDROOTMOUNTPOINT}/.nomedia
    chown root:sdcard_rw ${CLOUDROOTMOUNTPOINT}/.nomedia
    chmod 0644 ${CLOUDROOTMOUNTPOINT}/.nomedia

fi

if [[ ! -d ${CACHE} ]]; then

    mkdir -p ${CACHE}
    chown root:sdcard_rw ${CACHE}
    chmod 0775 ${CACHE}

fi

if [[ -d ${CACHE} ]]; then

    chown root:sdcard_rw ${CACHE}
    chmod 0775 ${CACHE}

fi

if [[ ! -d ${CACHE_BACKEND} ]]; then

    mkdir -p ${CACHE_BACKEND}

fi

if [[ -d ${CACHE_BACKEND} ]]; then

    chown root:sdcard_rw ${CACHE_BACKEND}
    chmod 0775 ${CACHE_BACKEND}

fi

if [[ ! -L ${RUNTIME_R}/cloud ]]; then

    ln -sf ${CLOUDROOTMOUNTPOINT} ${RUNTIME_R}/cloud

fi

if [[ ! -L ${RUNTIME_W}/cloud ]]; then

    ln -sf ${CLOUDROOTMOUNTPOINT} ${RUNTIME_W}/cloud

fi

if [[ ! -L ${RUNTIME_D}/cloud ]]; then

    ln -sf ${CLOUDROOTMOUNTPOINT} ${RUNTIME_D}/cloud

fi

if [[ -e ${USER_CONF} ]]; then

    cp ${USER_CONF} ${CONFIGFILE}
    chmod 0600 ${CONFIGFILE}

fi

until NET_CHK || [[ ${COUNT} = 60 ]]; do 

    sleep 5
    ((++COUNT))

done >> /dev/null 2>&1

echo "Default CACHEMODE ${CACHEMODE}"

${HOME}/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: | 

    while read remote; do

        echo

        DISABLE=0
        READONLY=0

        custom_params

        if [[ ${DISABLE} = 1 ]] || [[ -e ${USER_CONFDIR}/.${remote}.disable ]]; then

            echo "${remote} disabled by user"
            continue

        fi

        sd_unbind
        rclone_mount
        sd_binder

    done

echo

if $(/sbin/rclone serve http ${CLOUDROOTMOUNTPOINT} --addr ${HTTP_ADDR} --no-checksum --no-modtime --read-only >> /dev/null 2>&1 &); then

    echo "Notice: /mnt/cloud served via HTTP at: http://${HTTP_ADDR}"

fi

if $(/sbin/rclone serve ftp ${CLOUDROOTMOUNTPOINT} --addr ${FTP_ADDR} --no-checksum --no-modtime --read-only >> /dev/null 2>&1 &); then

    echo "Notice: /mnt/cloud served via FTP at: ftp://${FTP_ADDR}"

fi

echo
echo "...done"

exit
