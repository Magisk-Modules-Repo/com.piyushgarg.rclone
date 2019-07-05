#!/system/bin/sh

MODDIR=${0%/*}

IMGDIR=/sbin/.core/img
id=com.piyushgarg.rclone

USER_CONFDIR=/sdcard/.rclone
CLOUDROOTMOUNTPOINT=/mnt/cloud
SCRIPTPID=$$

if [ -d ${IMGDIR}/${id} ]; then

    HOME=${IMGDIR}/${id}

else

    HOME=${MODDIR}

fi

help () { 

    $HOME/rclone help
    echo
    echo 'Wrapper Commands:'
    echo '  disable         Disable a specified remote which exist in rclone.conf.'
    echo '  remount         Remount the remotes inside rclone.conf except disabled.'
    echo '  unmount         Kill rclone & unmount all remotes.'

}

disable () {
    
    echo "disabling remote ${2}"
    touch ${USER_CONFDIR}/.${2}.disable

}

unmount () {

    kill $(pgrep -f rclone| grep -v $SCRIPTPID) >> /dev/null 2>&1
    sleep 1
    umount -f ${CLOUDROOTMOUNTPOINT}/* >> /dev/null 2>&1
    sleep 3
    rm -r ${CLOUDROOTMOUNTPOINT} >> /dev/null 2>&1

}

remount () { 

    unmount
    ${HOME}/service.sh

}

if [[ ${1} = disable ]]; then

    disable

elif [[ ${1} = remount ]]; then

    remount

elif [[ ${1} = unmount ]]; then

    unmount

elif [[ ${1} = help ]]; then

    help

elif [[ -z ${1} ]]; then

    help

else

    ${HOME}/rclone $*
    
fi
