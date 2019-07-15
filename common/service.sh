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
    ln -sf ${UPDDIR}/${id}/fusermount /sbin/fusermount
    ln -sf ${UPDDIR}/${id}/rclone-mount /sbin/rclone-mount
    HOME=${UPDDIR}/${id}

elif [ -e ${IMGDIR}/${id}/rclone-wrapper.sh ]; then

    ln -sf ${IMGDIR}/${id}/rclone-wrapper.sh /sbin/rclone
    ln -sf ${IMGDIR}/${id}/fusermount /sbin/fusermount
    ln -sf ${IMGDIR}/${id}/rclone-mount /sbin/rclone-mount
    HOME=${IMGDIR}/${id}

else

    ln -sf ${MODDIR}/rclone-wrapper.sh /sbin/rclone
    ln -sf ${MODDIR}/fusermount /sbin/fusermount
    ln -sf ${MODDIR}/rclone-mount /sbin/rclone-mount
    HOME=${MODDIR}

fi

#MODULE VARS
USER_CONFDIR=/sdcard/.rclone
USER_CONF=${USER_CONFDIR}/rclone.conf
CONFIGFILE=${HOME}/.config/rclone/rclone.conf
LOGFILE=${USER_CONFDIR}/rclone.log
LOGLEVEL=NOTICE
RUNTIME_R=/mnt/runtime/read
RUNTIME_W=/mnt/runtime/write
RUNTIME_DEF=/mnt/runtime/default
SD_BINDPOINT=$RUNTIME_DEF/emulated/0/cloud
CLOUDROOTMOUNTPOINT=/mnt/cloud

#RCLONE PARAMETERS
DISABLE=0
BUFFERSIZE=0
CACHEMAXSIZE=5M
DIRCACHETIME=1h
ATTRTIMEOUT=1h
CACHEINFOAGE=1h
READAHEAD=64k
CACHEMODE=off
CACHE=${USER_CONFDIR}/.cache
CACHE_BACKEND=${USER_CONFDIR}/.cache-backend
HTTP_ADDR=127.0.0.1:38762
FTP_ADDR=127.0.0.1:38763

if [[ -z ${INTERACTIVE} ]]; then

    INTERACTIVE=0

fi


if [[ ! -d ${HOME}/.config/rclone ]]; then

    mkdir -p ${HOME}/.config/rclone

fi

custom_params () {

    PARAMS="BUFFERSIZE CACHEMAXSIZE DIRCACHETIME READAHEAD CACHEMODE DISABLE READONLY"

    BAD_SYNTAX="(^\s*#|^\s*$|^\s*[a-z_][^[:space:]]*=[^;&\(\`]*$)"

    if [[ -e $USER_CONFDIR/.$remote.param ]]; then
    
        echo "Found .$remote.param"

        if ! [[ $(egrep -q -iv "$BAD_SYNTAX" $USER_CONFDIR/.$remote.param) ]]; then

            echo "loading .$remote.param"

            for PARAM in ${PARAMS[@]}; do

                while read -r VAR; do

                    if [[ "$(echo "${VAR}" |grep -w "$PARAM")" ]]; then
                        echo "Importing ${VAR}"
                        eval $(echo "${VAR}" |cut -d ' ' -f 1)
                    fi

                done < $USER_CONFDIR/.$remote.param

            done

        else

            echo ".$remote.param contains bad syntax"

        fi

    fi


}

NET_CHK() {

    ping -c 5 google.com

}

COUNT=0

if [[ ${INTERACTIVE} = 0 ]]; then

    until [[ $(getprop sys.boot_completed) = 1 ]] && [[ $(getprop dev.bootcomplete) = 1 ]] && [[ $(getprop service.bootanim.exit) = 1 ]] && [[ $(getprop init.svc.bootanim) = stopped ]] && [[ -e ${USER_CONF} ]] || [[ ${COUNT} -eq 240 ]]; do

        sleep 5
        ((++COUNT))

    done

fi

sleep 5

if [[ ${COUNT} -eq 240 ]] || [[ ! -d /sdcard/Android ]]; then

    exit 0

fi

if [[ -e ${USER_CONFDIR}/.disable ]]; then 

    exit 0

fi

if [[ ! -d ${CLOUDROOTMOUNTPOINT} ]]; then

    mkdir -p ${CLOUDROOTMOUNTPOINT}
    chown root:sdcard_rw ${CLOUDROOTMOUNTPOINT}
    touch ${CLOUDROOTMOUNTPOINT}/.nomedia
    chmod 0644 ${CLOUDROOTMOUNTPOINT}/.nomedia

fi

if [[ ! -e ${CLOUDROOTMOUNTPOINT}/.nomedia ]]; then

    touch ${CLOUDROOTMOUNTPOINT}/.nomedia
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

if [[ ! -L ${RUNTIME_DEF}/cloud ]]; then

    ln -sf ${CLOUDROOTMOUNTPOINT} ${RUNTIME_DEF}/cloud

fi

if [[ ! -d ${SD_BINDPOINT} ]] && [[ -e $USER_CONFDIR/.bindsd ]]; then

   mkdir ${SD_BINDPOINT} >> /dev/null 2>&1

fi

if [[ -d ${SD_BINDPOINT} ]]; then

    chown root:sdcard_rw ${SD_BINDPOINT}
    chmod 0775 ${SD_BINDPOINT}

fi

if [[ -d ${RUNTIME_DEF} ]] && [[ ! -e ${SD_BINDPOINT}/.bound ]] && [[ -e $USER_CONFDIR/.bindsd ]]; then

    su -M -p -c mount -o noatime,bind ${CLOUDROOTMOUNTPOINT} ${SD_BINDPOINT} && touch ${CLOUDROOTMOUNTPOINT}/.bound

fi

if [[ -e ${USER_CONF} ]]; then

    cp ${USER_CONF} ${CONFIGFILE}
    chmod 0600 ${CONFIGFILE}

fi

if [[ -e ${USER_CONFDIR}/.nocache ]]; then

    CACHEMODE=off

fi

if [[ -e ${USER_CONFDIR}/.mincache ]]; then

    CACHEMODE=minimal

fi

if [[ -e $USER_CONFDIR/.writecache ]]; then

    CACHEMODE=writes

fi

if [[ -e $USER_CONFDIR/.fullcache ]]; then

    CACHEMODE=full

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

                if [[ ${READONLY} = 1 ]]; then

                     READONLY=" --read-only "

                else

                     READONLY=" "
                fi

                echo "[${remote}] available at: -> [${CLOUDROOTMOUNTPOINT}/${remote}]"
                
                mkdir -p ${CLOUDROOTMOUNTPOINT}/${remote}
                
                su -M -p -c nice -n 19 ionice -c 2 -n 7 $HOME/rclone mount ${remote}: ${CLOUDROOTMOUNTPOINT}/${remote} --config ${CONFIGFILE} --log-file ${LOGFILE} --log-level ${LOGLEVEL} --cache-dir ${CACHE} --cache-chunk-path ${CACHE_BACKEND} --cache-db-path ${CACHE_BACKEND} --cache-tmp-upload-path ${CACHE} --vfs-cache-mode ${CACHEMODE} --cache-chunk-no-memory --cache-chunk-size 1M --cache-chunk-total-size ${CACHEMAXSIZE} --use-mmap --buffer-size ${BUFFERSIZE} --max-read-ahead ${READAHEAD} --dir-cache-time ${DIRCACHETIME} --attr-timeout ${DIRCACHETIME} --cache-info-age ${CACHEINFOAGE} --no-modtime --uid 0 --gid 1015 --allow-other --dir-perms 0775 --file-perms 0644 --umask 002 ${READONLY} --daemon & >> /dev/null 2>&1

                sleep 5
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
