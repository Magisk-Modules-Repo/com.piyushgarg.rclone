#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

echo "UNmounting remotes..."
CONFIGFILE=/sdcard/rclone.conf
HOME=/mnt
CLOUDROOTMOUNTPOINT=$HOME/cloud/
mkdir -p $CLOUDROOTMOUNTPOINT

rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |
        while read remote; do
                echo "UNmounting... $remote"
                umount -f ${CLOUDROOTMOUNTPOINT}/${remote}
                sleep 1
        done

#send SIGINT signal
killall -2 rclone
echo "...done"
