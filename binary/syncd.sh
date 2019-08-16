#!/system/bin/sh

echo $$ >> ${PIDFILE}

while true; do

${HOME}/inotifywait "/storage/emulated/${PROFILE}/${SYNCDIR}" -e modify,create,moved_to,close_write -q >> /dev/null 2>&1

sleep 5

if [[ ${SYNCWIFI} = 1 ]]; then

    until ping -I wlan0 -c 1 ${NETCHK_ADDR}; do
        
        sleep 300
        
    done
    
nice -n 19 ionice -c 2 -n 7 ${HOME}/rclone copy "/storage/emulated/${PROFILE}/${SYNCDIR}" "$CLOUDROOTMOUNTPOINT/${remote}/${SYNCDIR}" --retries-sleep=10m --retries 6 --transfers 1 --multi-thread-streams 1 >> /dev/null 2>&1

else

nice -n 19 ionice -c 2 -n 7 ${HOME}/rclone copy "/storage/emulated/${PROFILE}/${SYNCDIR}" "$CLOUDROOTMOUNTPOINT/${remote}/${SYNCDIR}" --retries-sleep=10m --retries 6 --transfers 1 --multi-thread-streams 1 >> /dev/null 2>&1

fi

done