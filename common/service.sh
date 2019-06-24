#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
IMG=/sbin/.core/img
id=rclone-mount

if [ -d $IMG/$id ]; then

    ln -sf $IMG/$id/rclone /sbin/rclone
    ln -sf $IMG/$id/fusermount /sbin/fusermount

else

    ln -sf $MODDIR/rclone /sbin/rclone
    ln -sf $MODDIR/fusermount /sbin/fusermount
    
fi

#RCLONE PARAMETERS
BUFFERSIZE=8M
CACHEMAXSIZE=256M
DIRCACHETIME=24h
READAHEAD=128k

CONFIGFILE=/sdcard/rclone.conf
LOGFILE=/sdcard/rclone.log
HOME=/mnt
CLOUDROOTMOUNTPOINT=$HOME/cloud
CACHE=/mnt/runtime/default/rclone-cache
CACHE_BACKEND=/mnt/runtime/default/rc-cache-backend

mkdir -p $CLOUDROOTMOUNTPOINT
mkdir -p $CACHE
mkdir -p $CACHE_BACKEND

ln -sf $CLOUDROOTMOUNTPOINT /mnt/runtime/read/cloud
ln -sf $CLOUDROOTMOUNTPOINT /mnt/runtime/write/cloud

until [[ $(getprop sys.boot_completed) = 1 ]] && [[ $(getprop dev.bootcomplete) = 1 ]] && [[ $(getprop service.bootanim.exit) = 1 ]] && [[ $(getprop init.svc.bootanim) = stopped ]] && [[ -e $CONFIGFILE ]] || [[ $COUNT -eq 100 ]]; do


    sleep 5
    ((++COUNT))
    
    
done

sleep 10

#sh -c "$MODDIR/system/bin/rclone mount piyushDOTgarg_shopDOTmega: ${CLOUDROOTMOUNTPOINT}/piyushDOTgarg_shopDOTmega -vv --config ${CONFIGFILE} --attr-timeout 10m --cache-dir=/storage/cache --vfs-cache-mode writes --vfs-cache-max-age 168h0m0s --log-file /sdcard/dns.log --allow-other --gid 1015" &

echo "mounting remotes..."

$MODDIR/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |
        while read line; do
                echo "mounting... $line"
                mkdir -p ${CLOUDROOTMOUNTPOINT}/${line}
                $MODDIR/rclone mount ${line}: ${CLOUDROOTMOUNTPOINT}/${line} --config ${CONFIGFILE} --max-read-ahead ${READAHEAD} --buffer-size ${BUFFERSIZE} --dir-cache-time ${DIRCACHETIME} --poll-interval 5m --attr-timeout ${DIRCACHETIME} --vfs-cache-mode writes --vfs-read-chunk-size 2M --vfs-read-chunk-size-limit 10M --vfs-cache-max-age 168h0m0s --vfs-cache-max-size ${CACHEMAXSIZE} --cache-dir=${CACHE} --cache-chunk-path ${CACHE_BACKEND} --cache-chunk-clean-interval 10m0s --log-file ${LOGFILE} --allow-other --gid 1015 --daemon
                sleep 5
        done

echo "...done"

