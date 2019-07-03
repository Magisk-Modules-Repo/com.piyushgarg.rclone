#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
MODDIR=""
#sleep 120
echo "UNmounting remotes..."
CONFIGFILE=/sdcard/rclone.conf
HOME=/mnt
CLOUDROOTMOUNTPOINT=$HOME/cloud/
mkdir -p $CLOUDROOTMOUNTPOINT

$MODDIR/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |
        while read line; do
                echo "UNmounting... $line"
                umount -f ${CLOUDROOTMOUNTPOINT}/${line}
                sleep 1
        done

echo "...done"

