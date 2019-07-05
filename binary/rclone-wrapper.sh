#!/system/xbin/bash

MODDIR=${0%/*}

#. $MODDIR/module.prop >> /dev/null 2>&1

IMGDIR=/sbin/.core/img
id=com.piyushgarg.rclone

USER_CONFDIR=/sdcard/.rclone
CLOUDROOTMOUNTPOINT=/mnt/cloud

if [ -d ${IMGDIR}/${id} ]; then

    HOME=${IMGDIR}/${id}

else

    HOME=$={MODDIR}
    
fi

disable () {
    
    touch ${USER_CONFDIR}/.$*.disable
}

unmount () {
    
    umount -f ${CLOUDROOTMOUNTPOINT}/* >> /dev/null 2>&1
    kill -9 $(pgrep -x rclone)  >> /dev/null 2>&1
    
    rm -r ${CLOUDROOTMOUNTPOINT} >> /dev/null 2>&1
}


remount () { 

    umount -f ${CLOUDROOTMOUNTPOINT}/* >> /dev/null 2>&1
    sleep 1
    ${HOME}/service.sh

}

if [[ ${1} = disable ]]; then

    echo "disabling remote ${2}"
    touch $USER_CONFDIR/.${2}.disable

elif [[ ${1} = remount ]]; then

    remount
    
elif [[ ${1} = unmount ]]; then

    unmount
    
else

    $HOME/rclone $*
    
fi

