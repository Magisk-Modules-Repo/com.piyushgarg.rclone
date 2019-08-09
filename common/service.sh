#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will work
# if Magisk changes it's mount point in the future

PATH=/system/bin:/sbin:/sbin/.core/busybox:/system/xbin

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
SYSBIN=/system/bin
CLOUDROOTMOUNTPOINT=/mnt/cloud
USER_CONFDIR=/sdcard/.rclone
USER_CONF=${USER_CONFDIR}/rclone.conf
DATA_MEDIA=/data/media/0
RUNTIME_R=/mnt/runtime/read
RUNTIME_W=/mnt/runtime/write
RUNTIME_D=/mnt/runtime/default
BINDPOINT_R=${RUNTIME_R}/emulated/0/Cloud
BINDPOINT_W=${RUNTIME_W}/emulated/0/Cloud
BINDPOINT_D=${RUNTIME_D}/emulated/0/Cloud
SD_BINDPOINT=${BINDPOINT_D}
DISABLE=0
NETCHK=1
NETCHK_ADDR=google.com

#RCLONE PARAMETERS
CONFIGFILE=${HOME}/.config/rclone/rclone.conf
LOGFILE=${USER_CONFDIR}/rclone.log
LOGLEVEL=NOTICE
CACHE=${USER_CONFDIR}/.cache
CACHE_BACKEND=${USER_CONFDIR}/.cache-backend
CACHEMODE=off
READCHUNKSIZE=1M
CACHEMAXSIZE=1G
CHUNKSIZE=1M
CHUNKTOTAL=1G
CACHEWORKERS=1
CACHEINFOAGE=1h0m0s
DIRCACHETIME=30m0s
ATTRTIMEOUT=30s
BUFFERSIZE=0
READAHEAD=128k
M_UID=0
M_GID=1015
DIRPERMS=0775
FILEPERMS=0644
UMASK=002
BINDSD=0
HTTP=1
HTTP_ADDR=127.0.0.1:38762
FTP=1
FTP_ADDR=127.0.0.1:38763

if [[ -z ${INTERACTIVE} ]]; then

    INTERACTIVE=0

fi

if [[ ! -d ${HOME}/.config/rclone ]]; then

    mkdir -p ${HOME}/.config/rclone

fi

custom_params () {

    if [[ ${remote} = global ]]; then

        PARAMS="DISABLE LOGFILE LOGLEVEL CACHEMODE CHUNKSIZE CHUNKTOTAL CACHEWORKERS CACHEINFOAGE DIRCACHETIME ATTRTIMEOUT BUFFERSIZE READAHEAD M_UID M_GID DIRPERMS FILEPERMS READONLY BINDSD ADD_PARAMS REPLACE_PARAMS NETCHK NETCHK_ADDR HTTP FTP HTTP_ADDR FTP_ADDR"

    else

        PARAMS="DISABLE LOGFILE LOGLEVEL CACHEMODE CHUNKSIZE CHUNKTOTAL CACHEWORKERS CACHEINFOAGE DIRCACHETIME ATTRTIMEOUT BUFFERSIZE READAHEAD M_UID M_GID DIRPERMS FILEPERMS READONLY BINDSD SDBINDPOINT ADD_PARAMS REPLACE_PARAMS"

    fi

    BAD_SYNTAX="(^\s*#|^\s*$|^\s*[a-z_][^[:space:]]*=[^;&\(\`]*$)"

    if [[ -e ${USER_CONFDIR}/.${remote}.param ]]; then

        echo "Found .${remote}.param"

        if ! [[ $(egrep -q -iv "${BAD_SYNTAX}" ${USER_CONFDIR}/.${remote}.param) ]]; then

            echo "loading .${remote}.param"

            for PARAM in ${PARAMS[@]}; do

                while read -r VAR; do

                    if [[ "$(echo "${VAR}" |grep "$PARAM=")" ]]; then
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

global_params () {

    remote=global
    custom_params
    unset remote
    echo

}

net_chk() {

    ping -c 5 ${NETCHK_ADDR}

}

sd_unbind () {

    if [[ -z ${SDBINDPOINT} ]]; then

        UNBINDPOINT=${BINDPOINT_D}/${remote}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${BINDPOINT_R}/${remote}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${BINDPOINT_W}/${remote}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

    else 

        USER_BINDPOINT=${SDBINDPOINT}

        UNBINDPOINT=${RUNTIME_D}/emulated/0/${USER_BINDPOINT}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${RUNTIME_R}/emulated/0/${USER_BINDPOINT}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        UNBINDPOINT=${RUNTIME_W}/emulated/0/${USER_BINDPOINT}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        fi

}

sd_binder () {

    if [[ -d ${RUNTIME_D} ]] && [[ ${BINDSD} = 1 ]]; then

        if [[ -z ${SDBINDPOINT} ]]; then 

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
            
            echo "[$remote] available at: -> [/sdcard/Cloud/${remote}]"

        else 

            mkdir ${DATA_MEDIA}/${SDBINDPOINT} >> /dev/null 2>&1
            chown media_rw:media_rw ${DATA_MEDIA}/${SDBINDPOINT}

            USER_BINDPOINT=${SDBINDPOINT}
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

            echo "[$remote] available at: -> [/sdcard/${SDBINDPOINT}]"

        fi

    fi

    unset SDBINDPOINT
    unset BINDSD

}

rclone_mount () {

    if [[ ${READONLY} = 1 ]]; then

        READONLY=" --read-only "

    else

        READONLY=" "

    fi
    
    if [[ ${ADD_PARAMS} = 0 ]]; then
    
        unset ADD_PARAMS
        
    fi
    
    if [[ ${REPLACE_PARAMS} = 0 ]]; then
    
        unset REPLACE_PARAMS
        
    fi

    if [[ -z ${REPLACE_PARAMS} ]]; then

        RCLONE_PARAMS=" --log-file ${LOGFILE} --log-level ${LOGLEVEL} --vfs-cache-mode ${CACHEMODE} --cache-dir ${CACHE} --cache-chunk-path ${CACHE_BACKEND} --cache-db-path ${CACHE_BACKEND} --cache-tmp-upload-path ${CACHE} --vfs-read-chunk-size ${READCHUNKSIZE} --vfs-cache-max-size ${CACHEMAXSIZE} --cache-chunk-size ${CHUNKSIZE} --cache-chunk-total-size ${CHUNKTOTAL} --cache-workers ${CACHEWORKERS} --cache-info-age ${CACHEINFOAGE} --dir-cache-time ${DIRCACHETIME} --attr-timeout ${ATTRTIMEOUT} --cache-chunk-no-memory --use-mmap --buffer-size ${BUFFERSIZE} --max-read-ahead ${READAHEAD} --no-modtime --no-checksum --uid ${M_UID} --gid ${M_GID} --allow-other --dir-perms ${DIRPERMS} --file-perms ${FILEPERMS} --umask ${UMASK} ${READONLY} ${ADD_PARAMS} "

    elif [[ ! -z ${REPLACE_PARAMS} ]]; then

        RCLONE_PARAMS=" ${REPLACE_PARAMS} "

    fi

    if [[ -z ${ADD_PARAMS} ]]; then

        ADD_PARAMS=" "

    elif [[ ! -z ${ADD_PARAMS} ]]; then

        ADD_PARAMS=" ${ADD_PARAMS} "

    fi

    echo "[${remote}] available at: -> [${CLOUDROOTMOUNTPOINT}/${remote}]"

    mkdir -p ${CLOUDROOTMOUNTPOINT}/${remote}

    su -M -p -c nice -n 19 ionice -c 2 -n 7 $HOME/rclone mount ${remote}: ${CLOUDROOTMOUNTPOINT}/${remote} --config ${CONFIGFILE} ${RCLONE_PARAMS} --daemon & >> /dev/null 2>&1

    unset RCLONE_PARAMS
    unset REPLACE_PARAMS
    unset ADD_PARAMS

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

if [[ ${COUNT} -eq 240 ]] || [[ ! -d /sdcard/Android ]]; then

    exit 0

fi

if [[ ! -d ${USER_CONFDIR} ]]; then 

    mkdir ${USER_CONFDIR}

fi

if [[ -e ${USER_CONFDIR}/.disable ]] && [[ ${INTERACTIVE} = 0 ]]; then 

    exit 0

fi

global_params

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

if [[ ${NETCHK} = 1 ]]; then

    until net_chk || [[ ${COUNT} = 60 ]]; do 

        sleep 5
        ((++COUNT))

    done >> /dev/null 2>&1

fi

echo "Default CACHEMODE ${CACHEMODE}"

sleep 5

${HOME}/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: | 

    while read remote; do

        echo

        list_remote=${remote}
        DISABLE=0
        READONLY=0

        global_params >> /dev/null 2>&1

        remote=${list_remote}

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

if [[ ${HTTP} = 1 ]]; then

    if $(/sbin/rclone serve http ${CLOUDROOTMOUNTPOINT} --addr ${HTTP_ADDR} --no-checksum --no-modtime --read-only >> /dev/null 2>&1 &); then

        echo "Notice: /mnt/cloud served via HTTP at: http://${HTTP_ADDR}"

    fi

fi

if [[ ${FTP} = 1 ]]; then

    if $(/sbin/rclone serve ftp ${CLOUDROOTMOUNTPOINT} --addr ${FTP_ADDR} --no-checksum --no-modtime --read-only >> /dev/null 2>&1 &); then

        echo "Notice: /mnt/cloud served via FTP at: ftp://${FTP_ADDR}"

    fi
    
fi

echo
echo "...done"

exit
