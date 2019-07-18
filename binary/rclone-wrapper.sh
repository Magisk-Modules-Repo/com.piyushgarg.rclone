#!/system/bin/sh

MODDIR=${0%/*}
UPDDIR=/data/adb/modules_update
IMGDIR=/sbin/.core/img
id=com.piyushgarg.rclone

USER_CONFDIR=/sdcard/.rclone
CLOUDROOTMOUNTPOINT=/mnt/cloud
RUNTIME_MNT_R=/mnt/runtime/read/emulated/0/cloud
RUNTIME_MNT_W=/mnt/runtime/write/emulated/0/cloud
RUNTIME_MNT_DEF=/mnt/runtime/default/emulated/0/cloud
DATA_MNT=/data/media/0/cloud

SCRIPTPID=$$

export INTERACTIVE=1

if [ -e ${UPDDIR}/${id}/rclone ]; then

    HOME=${UPDDIR}/${id}
    
elif [ -e ${IMGDIR}/${id}/rclone ]; then

    HOME=${IMGDIR}/${id}

else

    HOME=${MODDIR}

fi

config () {
    
    if [[ ! -d ${USER_CONFDIR} ]]; then 

    mkdir ${USER_CONFDIR}

    fi
    
    if [[ -e ${USER_CONFDIR}/rclone.conf ]]; then
    
        cp ${USER_CONFDIR}/rclone.conf ${HOME}/.config/rclone/rclone.conf
    
    fi
     
    ${HOME}/rclone config && cp ${HOME}/.config/rclone/rclone.conf ${USER_CONFDIR}/rclone.conf && echo && ${HOME}/rclone-wrapper.sh remount

}

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

    echo "Killing & Unmounting Remotes...."
    
    echo
    
    kill $(pgrep -f rclone| grep -v ${SCRIPTPID}) >> /dev/null 2>&1
    
    sleep 1
    
    umount -lf ${CLOUDROOTMOUNTPOINT}/* >> /dev/null 2>&1
    
    umount -lf ${CLOUDROOTMOUNTPOINT} >> /dev/null 2>&1
    
    
    umount -lf ${RUNTIME_MNT_DEF}/ >> /dev/null 2>&1
        
        
    umount -lf ${RUNTIME_MNT_DEF} >> /dev/null 2>&1
    
    su -M -c $HOME/rclone purge ${RUNTIME_MNT_DEF} >> /dev/null 2>&1
    
    su -M -c $HOME/rclone purge ${DATA_MNT} >> /dev/null 2>&1
    
    
    $HOME/rclone purge ${CLOUDROOTMOUNTPOINT} >> /dev/null 2>&1

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
    
elif [[ ${1} = config ]]; then

    config
     
elif [[ ${1} = help ]]; then

    help
    
elif [[ ${1} = --help ]]; then

    help

elif [[ -z ${1} ]]; then

    help

else

    ${HOME}/rclone $*
    
fi
