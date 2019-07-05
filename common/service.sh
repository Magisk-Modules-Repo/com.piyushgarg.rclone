#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will work
# if Magisk changes it's mount point in the future

MODDIR=${0%/*}

IMGDIR=/sbin/.core/img
id=com.piyushgarg.rclone

if [ -d ${IMGDIR}/${id} ]; then

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

#/sdcard/rclone.conf is really a sensitive file containing all the important tokens and is exposed to all the apps.
#Do we really want to keep it there after use? Lets decide and close the loop.
USER_CONF=${USER_CONFDIR}/rclone.conf

CONFIGFILE=${HOME}/.config/rclone/rclone.conf
LOGFILE=/sdcard/rclone.log
HOME=${MODDIR}
CLOUDROOTMOUNTPOINT=/mnt/cloud

#RCLONE PARAMETERS
DISABLE=0
BUFFERSIZE=8M
CACHEMAXSIZE=256M
DIRCACHETIME=24h
READAHEAD=128k
CACHEMODE=writes
CACHE=/data/rclone/cache
CACHE_BACKEND=/data/rclone/cache-backend
HTTP_ADDR=127.0.0.1:38762
FTP_ADDR=127.0.0.1:38763

if [[ ! -d ${HOME}/.config/rclone ]]; then

    mkdir -p ${HOME}/.config/rclone

fi

if [[ -e ${USER_CONFDIR}/.disable ]]; then 

    exit 0

fi

custom_params () {

    PARAMS="BUFFERSIZE CACHEMAXSIZE DIRCACHETIME READAHEAD CACHEMODE DISABLE"

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

if [[ ! -d ${CLOUDROOTMOUNTPOINT} ]]; then

    mkdir -p ${CLOUDROOTMOUNTPOINT}

fi

if [[ ! -d ${CACHE} ]]; then

    mkdir -p ${CACHE}

fi

if [[ ! -d ${CACHE_BACKEND} ]]; then

    mkdir -p ${CACHE_BACKEND}

fi

if [[ ! -L /mnt/runtime/read/cloud ]]; then

    ln -sf ${CLOUDROOTMOUNTPOINT} /mnt/runtime/read/cloud
    
fi

if [[ ! -L /mnt/runtime/write/cloud ]]; then
    
    ln -sf ${CLOUDROOTMOUNTPOINT} /mnt/runtime/write/cloud
    
fi

until [[ $(getprop sys.boot_completed) = 1 ]] && [[ $(getprop dev.bootcomplete) = 1 ]] && [[ $(getprop service.bootanim.exit) = 1 ]] && [[ $(getprop init.svc.bootanim) = stopped ]] && [[ -e ${USER_CONF} ]] || [[ ${COUNT} -eq 240 ]]; do

    sleep 5
    ((++COUNT))

done

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

sleep 10

echo "Default CACHEMODE ${CACHEMODE}"

${HOME}/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |

        while read remote; do

                echo

                DISABLE=0

                custom_params

                if [[ ${DISABLE} = 1 ]] || [[ -e ${USER_CONFDIR}/.${remote}.disable ]]; then

                    echo "${remote} disabled by user"
                    continue

                fi

                echo "[${remote}] available at: -> [${CLOUDROOTMOUNTPOINT}/${remote}]"
                mkdir -p ${CLOUDROOTMOUNTPOINT}/${remote}
                su -M -p -c $HOME/rclone mount ${remote}: ${CLOUDROOTMOUNTPOINT}/${remote} --config ${CONFIGFILE} --max-read-ahead ${READAHEAD} --buffer-size ${BUFFERSIZE} --dir-cache-time ${DIRCACHETIME} --poll-interval 5m --attr-timeout ${DIRCACHETIME} --vfs-cache-mode ${CACHEMODE} --vfs-read-chunk-size 2M --vfs-read-chunk-size-limit 10M --vfs-cache-max-age 10h0m0s --vfs-cache-max-size ${CACHEMAXSIZE} --cache-dir=${CACHE} --cache-chunk-path ${CACHE_BACKEND} --cache-chunk-clean-interval 10m0s --log-file ${LOGFILE} --allow-other --gid 1015 --daemon >> /dev/null 2>&1
                sleep 5
        done

echo

/sbin/rclone serve http ${CLOUDROOTMOUNTPOINT} --addr ${HTTP_ADDR} --no-checksum --no-modtime --read-only >> /dev/null 2>&1 &

echo "Notice: /mnt/cloud served via HTTP at: http://${HTTP_ADDR}"

/sbin/rclone serve ftp ${CLOUDROOTMOUNTPOINT} --addr ${FTP_ADDR} --no-checksum --no-modtime --read-only >> /dev/null 2>&1 &

echo "Notice: /mnt/cloud served via FTP at: ftp://${FTP_ADDR}"

echo
echo "...done"

exit
