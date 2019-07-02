#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will work
# if Magisk changes it's mount point in the future

MODDIR=${0%/*}
MODDIR=/data/adb/modules/com.piyushgarg.rclone

#. $MODDIR/module.prop >> /dev/null 2>&1

IMGDIR=/sbin/.core/img
id=com.piyushgarg.rclone

if [ -d $IMGDIR/$id ]; then

    ln -sf $IMGDIR/$id/rclone /sbin/rclone
    ln -sf $IMGDIR/$id/fusermount /sbin/fusermount
    ln -sf $IMGDIR/$id/rclone-mount /sbin/rclone-mount
else

    ln -sf $MODDIR/rclone /sbin/rclone
    ln -sf $MODDIR/fusermount /sbin/fusermount
    ln -sf $MODDIR/rclone-mount /sbin/rclone-mount

fi

#MODULE VARS
USER_CONFDIR=/sdcard/.rclone

#rclone.conf is really a sensitive file containing all the important tokens and is exposed to all the apps.
#Do we really want to keep it there after use? Lets decide and close the loop.
USER_CONF=$USER_CONFDIR/rclone.conf

CONFIGFILE=$MODDIR/rclone.conf
LOGFILE=/sdcard/rclone.log
HOME=/mnt
CLOUDROOTMOUNTPOINT=$HOME/cloud

#RCLONE PARAMETERS
BUFFERSIZE=8M
CACHEMAXSIZE=256M
DIRCACHETIME=24h
READAHEAD=128k
CACHEMODE=writes
CACHE=/data/rclone/cache
CACHE_BACKEND=/data/rclone/cache-backend

custom_params () {

    PARAMS="BUFFERSIZE CACHEMAXSIZE DIRCACHETIME READAHEAD CACHEMODE"
    BAD_SYNTAX="(^\s*#|^\s*$|^\s*[a-z_][^[:space:]]*=[^;&\(\`]*$)"

    if [[ -e $USER_CONFDIR/.$remote.param ]]; then

        if ! egrep -q -iv "$BAD_SYNTAX" $USER_CONFDIR/.$remote.param; then

            for PARAM in ${PARAMS[@]}; do

                while read -r VAR; do

                    if [[ "$(echo "${VAR}" |grep -w "$PARAM")" ]]; then

                        eval $(echo "${VAR}" |cut -d ' ' -f 1)

                    fi

                done < $USER_CONFDIR/.$remote.param

            done

        else

            echo ".$remote.param contains bad syntax"

        fi

    fi

}

if [[ ! -d $CLOUDROOTMOUNTPOINT ]]; then

    mkdir -p $CLOUDROOTMOUNTPOINT

fi

if [[ ! -d $CACHE ]]; then

    mkdir -p $CACHE

fi

if [[ ! -d $CACHE_BACKEND ]]; then

    mkdir -p $CACHE_BACKEND

fi

if [[ ! -L /mnt/runtime/read/cloud ]]; then

    ln -sf $CLOUDROOTMOUNTPOINT /mnt/runtime/read/cloud

fi

if [[ ! -L /mnt/runtime/write/cloud ]]; then

    ln -sf $CLOUDROOTMOUNTPOINT /mnt/runtime/write/cloud

fi

if [[ -e $USER_CONF ]]; then

    cp $USER_CONF $CONFIGFILE
    chmod 0600 $CONFIGFILE

fi

if [[ -e $USER_CONFDIR/.nocache ]]; then

    CACHEMODE=off

fi

if [[ -e $USER_CONFDIR/.mincache ]]; then

    CACHEMODE=minimal

fi

if [[ -e $USER_CONFDIR/.writecache ]]; then

    CACHEMODE=writes

fi

if [[ -e $USER_CONFDIR/.fullcache ]]; then

    CACHEMODE=full

fi

echo CACHEMODE will be ${CACHEMODE}.

/sbin/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |
        while read remote; do

                #ignore the remote which is not required.
                if [[ -e "${USER_CONFDIR}/${remote}.skip" ]]; then
                    echo "ignored [${remote}] as requested."
                    continue
                fi

                custom_params
                echo "[$remote] will be available at -> [${CLOUDROOTMOUNTPOINT}/${remote}]"
                mkdir -p ${CLOUDROOTMOUNTPOINT}/${remote}
                /sbin/rclone mount ${remote}: ${CLOUDROOTMOUNTPOINT}/${remote} --config ${CONFIGFILE} --max-read-ahead ${READAHEAD} --buffer-size ${BUFFERSIZE} --dir-cache-time ${DIRCACHETIME} --poll-interval 5m --attr-timeout ${DIRCACHETIME} --vfs-cache-mode ${CACHEMODE} --vfs-read-chunk-size 2M --vfs-read-chunk-size-limit 10M --vfs-cache-max-age 10h0m0s --vfs-cache-max-size ${CACHEMAXSIZE} --cache-dir=${CACHE} --cache-chunk-path ${CACHE_BACKEND} --cache-chunk-clean-interval 10m0s --log-file ${LOGFILE} --allow-other --gid 1015 --daemon
                sleep 5
        done

/sbin/rclone serve http ${CLOUDROOTMOUNTPOINT} --addr 127.0.0.1:38762 --no-checksum --no-modtime --read-only &

echo
echo "...done"

