#!/system/bin/sh

MODDIR=${0%/*}

IMGDIR=/sbin/.core/img
UPDDIR=/data/adb/modules_update
id=com.piyushgarg.rclone

if [ -d ${UPDDIR}/${id} ]; then

    HOME=${UPDDIR}/${id}

elif [ -e ${IMGDIR}/${id} ]; then

    HOME=${IMGDIR}/${id}

else

    HOME=${MODDIR}

fi

LD_LIBRARY_PATH=$HOME $HOME/fusermount $*