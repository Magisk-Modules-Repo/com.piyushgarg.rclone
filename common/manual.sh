#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future

MODDIR=${0%/*}

. $MODDIR/module.prop

IMGDIR=/sbin/.core/img

if [ -d $IMGDIR/$id ]; then

    ln -sf $IMGDIR/$id/rclone /sbin/rclone
    ln -sf $IMGDIR/$id/fusermount /sbin/fusermount

else

    ln -sf $MODDIR/rclone /sbin/rclone
    ln -sf $MODDIR/fusermount /sbin/fusermount
    
fi

#RCLONE PARAMETERS
BUFFERSIZE=8M
CACHEMAXSIZE=256M
DIRCACHETIME=24h
READAHEAD=128k

USER_CONF=/sdcard/rclone.conf
CONFIGFILE=$MODDIR/rclone.conf
LOGFILE=/sdcard/rclone.log
HOME=/mnt
CLOUDROOTMOUNTPOINT=$HOME/cloud
CACHE=/mnt/runtime/default/rclone-cache
CACHE_BACKEND=/mnt/runtime/default/rc-cache-backend

if [[ ! -d $CLOUDROOTMOUNTPOINT ]]; then

mkdir -p $CLOUDROOTMOUNTPOINT

fi

if [[ ! -d $CACHE ]]; then

mkdir -p $CACHE

fi

if [[ ! -d $CACHE_BACKEND ]]; then

mkdir -p $CACHE_BACKEND

fi

ln -sf $CLOUDROOTMOUNTPOINT /mnt/runtime/read/cloud
ln -sf $CLOUDROOTMOUNTPOINT /mnt/runtime/write/cloud

if [[ -e $USER_CONFIG ]]; then

    cp $USER_CONFIG $CONFIGFILE
    chmod 0600 $CONFIGFILE
    
fi

#sh -c "$MODDIR/system/bin/rclone mount piyushDOTgarg_shopDOTmega: ${CLOUDROOTMOUNTPOINT}/piyushDOTgarg_shopDOTmega -vv --config ${CONFIGFILE} --attr-timeout 10m --cache-dir=/storage/cache --vfs-cache-mode writes --vfs-cache-max-age 168h0m0s --log-file /sdcard/dns.log --allow-other --gid 1015" &

$MODDIR/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |
        while read line; do
                echo "mounting... $line"
                mkdir -p ${CLOUDROOTMOUNTPOINT}/${line}
                $MODDIR/rclone mount ${line}: ${CLOUDROOTMOUNTPOINT}/${line} --config ${CONFIGFILE} --max-read-ahead ${READAHEAD} --buffer-size ${BUFFERSIZE} --dir-cache-time ${DIRCACHETIME} --poll-interval 5m --attr-timeout ${DIRCACHETIME} --vfs-cache-mode writes --vfs-read-chunk-size 2M --vfs-read-chunk-size-limit 10M --vfs-cache-max-age 168h0m0s --vfs-cache-max-size ${CACHEMAXSIZE} --cache-dir=/storage/cache --cache-chunk-path /storage/cache-backend/ --cache-chunk-clean-interval 10m0s --log-file ${LOGFILE} --allow-other --gid 1015 --daemon
                sleep 5
        done

echo "...done"

