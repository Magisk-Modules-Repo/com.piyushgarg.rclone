#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
MODDIR=""
#sleep 120
echo "mounting remotes..."
CONFIGFILE=/sdcard/rclone.conf
CLOUDROOTMOUNTPOINT=/mnt/cloud
mkdir -p $CLOUDROOTMOUNTPOINT
mkdir -p /storage/cache/
mkdir -p /storage/cache-backend/

#sh -c "$MODDIR/system/bin/rclone mount piyushDOTgarg_shopDOTmega: ${CLOUDROOTMOUNTPOINT}/piyushDOTgarg_shopDOTmega -vv --config ${CONFIGFILE} --attr-timeout 10m --cache-dir=/storage/cache --vfs-cache-mode writes --vfs-cache-max-age 168h0m0s --log-file /sdcard/dns.log --allow-other --gid 1015" &

$MODDIR/system/bin/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |
        while read line; do
                echo "mounting... $line"
                mkdir -p ${CLOUDROOTMOUNTPOINT}/${line}
                sh -c "$MODDIR/system/bin/rclone mount ${line}: ${CLOUDROOTMOUNTPOINT}/${line} -vv --config ${CONFIGFILE} --attr-timeout 10m --cache-dir=/storage/cache --vfs-cache-mode writes --vfs-read-chunk-size 2M --vfs-read-chunk-size-limit 100M --vfs-cache-max-age 168h0m0s --cache-chunk-path /storage/cache-backend/ --cache-chunk-clean-interval 10m0s --log-file /sdcard/dns.log --allow-other --gid 1015 --daemon"
                sleep 2
        done

echo "...done"

