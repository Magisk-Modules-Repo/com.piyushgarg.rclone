#!/system/bin/sh

MODDIR="$(dirname "$(readlink -f "$0")")"
UPDDIR=/data/adb/modules_update
IMGDIR=/sbin/.core/img
id=com.piyushgarg.rclone

USER_CONFDIR=/sdcard/.rclone
USER_CONF=${USER_CONFDIR}/rclone.conf
CONFIGFILE=${HOME}/.config/rclone/rclone.conf
LOGFILE=${USER_CONFDIR}/rclone.log
LOGLEVEL=NOTICE
DATA_MEDIA=/data/media/0
RUNTIME_R=/mnt/runtime/read
RUNTIME_W=/mnt/runtime/write
RUNTIME_D=/mnt/runtime/default
BINDPOINT_R=${RUNTIME_R}/emulated/0/Cloud
BINDPOINT_W=${RUNTIME_W}/emulated/0/Cloud
BINDPOINT_D=${RUNTIME_D}/emulated/0/Cloud
SD_BINDPOINT=${BINDPOINT_D}
CLOUDROOTMOUNTPOINT=/mnt/cloud

SCRIPTPID=$$
export INTERACTIVE=1

## resolve links - $0 may be a link to module home
PRG="$0"

# need this for relative symlinks
while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG="`dirname "$PRG"`/$link"
  fi
done

echo $PRG

saveddir=`pwd`

MODDIR2=`dirname "$PRG"`

# make it fully qualified
MODDIR2=`cd "$MODIR2" && pwd`

cd "$saveddir"
#echo $MODDIR2

if [ -e ${UPDDIR}/${id}/rclone ]; then
    HOME=${UPDDIR}/${id}

elif [ -e ${IMGDIR}/${id}/rclone ]; then
    HOME=${IMGDIR}/${id}

elif [ -e ${MODDIR2}/${id}/rclone ]; then
    HOME=${MODDIR2}/${id}

else
    HOME=${MODDIR}
fi

echo $HOME

CONFIGFILE=${HOME}/.config/rclone/rclone.conf

custom_params () {

    PARAMS="DISABLE BINDSD BINDPOINT"

    BAD_SYNTAX="(^\s*#|^\s*$|^\s*[a-z_][^[:space:]]*=[^;&\(\`]*$)"

    if [[ -e $USER_CONFDIR/.$remote.param ]]; then

        echo "Found .$remote.param"

        if ! [[ $(egrep -q -iv "$BAD_SYNTAX" $USER_CONFDIR/.$remote.param) ]]; then

            echo "loading .$remote.param"

            for PARAM in ${PARAMS[@]}; do

                while read -r VAR; do

                    if [[ "$(echo "${VAR}" |grep -w "$PARAM")" ]]; then
                        echo "Importing ${VAR}"
                        eval $(echo "${VAR}" |cut -d ' ' -f 1)
                    fi

                done < $USER_CONFDIR/.$remote.param

            done

        else

            echo ".$remote.param contains bad syntax"

        fi

    fi

}

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

    $HOME/rclone purge ${CLOUDROOTMOUNTPOINT} >> /dev/null 2>&1

}

sd_unbind_func () {

    if [[ -z ${BINDPOINT} ]]; then

        UNBINDPOINT=${BINDPOINT_DEF}/${remote}

        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1
        
        UNBINDPOINT=${BINDPOINT_R}/${remote}
        
        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1
        
        UNBINDPOINT=${BINDPOINT_W}/${remote}
    
        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1
    
    else 
    
        USER_BINDPOINT=${BINDPOINT}

        UNBINDPOINT=${RUNTIME_D}/emulated/0/${USER_BINDPOINT}
        
        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1
        
        UNBINDPOINT=${RUNTIME_R}/emulated/0/${USER_BINDPOINT}
        
        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1
        
        UNBINDPOINT=${RUNTIME_W}/emulated/0/${USER_BINDPOINT}
        
        su -M -c umount -lf ${UNBINDPOINT} >> /dev/null 2>&1

        fi
    
}

sd_unbind () {

    ${HOME}/rclone listremotes --config ${CONFIGFILE} | cut -f1 -d: | while read remote; do
                echo
                custom_params
                sd_unbind_func

        done >> /dev/null 2>&1
}

remount () { 
    
    sd_unbind
    unmount
    ${HOME}/service.sh

}

if [[ ${1} = disable ]]; then

    disable

elif [[ ${1} = remount ]]; then

    remount

elif [[ ${1} = unmount ]]; then

    sd_unbind
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
