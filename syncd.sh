#!/system/bin/sh

MODDIR=${0%/*}
TMPDIR=${MODDIR}/.tmp
SYNC_PENDING=${TMPDIR}/${remote}.sync.pend

dump_battery () {
    BATTERY_DUMP="$(dumpsys battery)"
}

battery_level () {
    echo "${BATTERY_DUMP}" |grep level |cut -d ':' -f2 |cut -d ' ' -f2
}

ac_charge () {
    echo "${BATTERY_DUMP}" |grep -w "AC powered" |cut -d ":" -f2 |cut -d " " -f2
}

usb_charge () {
    echo "${BATTERY_DUMP}" |grep -w "USB powered" |cut -d ":" -f2 |cut -d " " -f2
}

echo $$ >> ${PIDFILE}

while true; do
    if [[ ! -e ${SYNC_PENDING} ]]; then
        ${MODDIR}/inotifywait "/storage/emulated/${PROFILE}/${SYNCDIR}" -e modify,create,moved_to,close_write -q >> /dev/null 2>&1 && touch ${SYNC_PENDING}
    fi

    while true; do
        sleep 5
        dump_battery
        if [[ $(battery_level) -gt ${SYNC_BATTLVL} ]] || [[ $(bettery_level) -eq ${SYNC_BATTLVL} ]] || [[ $(ac_charge) = true ]] || [[ $(usb_charge) = true ]]; then
            echo "Sync battery check success"
        else
            sleep 300
            continue
        fi
        if [[ $SYNC_CHARGE = 1 ]]; then
            if [[ $(ac_charge) = true ]] || [[ $(usb_charge) = true ]]; then
                echo "Sync charge check success"
            else
                echo "Sync charge check fail"
                sleep 300
                continue
            fi
        fi
        if [[ ${SYNC_WIFI} = 1 ]]; then
            if ! ping -I wlan0 -c 1 ${NETCHK_ADDR} >> /dev/null 2>&1; then
                echo "Sync wifi check fail"
                sleep 300
                continue
            else
                echo "Sync wifi check success"
            fi
        fi
        break
    done

    echo "Syncing..."
    nice -n 19 ionice -c 2 -n 7 ${MODDIR}/rclone copy "/storage/emulated/${PROFILE}/${SYNCDIR}" "$CLOUDROOTMOUNTPOINT/${remote}/${SYNCDIR}" --retries-sleep=10m --retries 6 --transfers 1 --multi-thread-streams 1 >> /dev/null 2>&1

    if [[ -e ${SYNC_PENDING} ]]; then
        rm ${SYNC_PENDING}
    fi
    echo "Sync finished!"
done
