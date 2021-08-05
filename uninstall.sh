echo "Un-mounting remotes..."
CONFIGFILE=/sdcard/.rclone/rclone.conf
CLOUDROOTMOUNTPOINT=/mnt/cloud/
mkdir -p $CLOUDROOTMOUNTPOINT

$MODDIR/rclone listremotes --config ${CONFIGFILE}|cut -f1 -d: |
while read line; do
    echo "Un-mounting [$line] ..."
    umount -f ${CLOUDROOTMOUNTPOINT}/${line}
    sleep 1
done

echo "... done"

# Don't modify anything after this
if [ -f $INFO ]; then
    while read LINE; do
        if [ "$(echo -n $LINE | tail -c 1)" == "~" ]; then
            continue
        elif [ -f "$LINE~" ]; then
            mv -f $LINE~ $LINE
        else
            rm -f $LINE
            while true; do
                LINE=$(dirname $LINE)
                [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
            done
        fi
    done < $INFO
    rm -f $INFO
fi
