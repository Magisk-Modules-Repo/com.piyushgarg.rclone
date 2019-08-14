#!/system/bin/sh

echo $$ >> ${PIDFILE}

while true; do

${HOME}/inotifywait "/storage/emulated/${PROFILE}/${SYNCDIR}" -e modify,create,moved_to,close_write -q >> /dev/null 2>&1

sleep 5

if [[ ${SYNCWIFI} = 1 ]]; then

    until ping -I wlan0 -c 1 ${NETCHK_ADDR}; do
        
        sleep 300
        
    done
    
    ${HOME}/rclone copy "/storage/emulated/${PROFILE}/${SYNCDIR}" "$CLOUDROOTMOUNTPOINT/${remote}/${SYNCDIR}" --retries-sleep=10m --retries 6 >> /dev/null 2>&1

else

    ${HOME}/rclone copy "/storage/emulated/${PROFILE}/${SYNCDIR}" "$CLOUDROOTMOUNTPOINT/${remote}/${SYNCDIR}" --retries-sleep=10m --retries 6 >> /dev/null 2>&1

fi

done