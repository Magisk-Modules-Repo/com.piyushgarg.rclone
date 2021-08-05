# Install script

ui_print "+ Extracting rclone to $MODPATH/rclone"
cp -af $MODPATH/common/binary/$ARCH/rclone $MODPATH/rclone

ui_print "+ Extracting fusermount to $MODPATH/system/bin/fusermount"
cp -af $MODPATH/common/binary/$ARCH/fusermount $MODPATH/system/bin/fusermount

ui_print "+ Extracting syncd.sh script to $MODPATH/syncd.sh"
cp -af $MODPATH/common/binary/syncd.sh $MODPATH/syncd.sh

ui_print "+ Extracting inotifywait to $MODPATH/inotifywait"
cp -af $MODPATH/common/binary/$ARCH/inotifywait $MODPATH/inotifywait

case $ARCH32 in
    arm)
        ui_print "+ Extracting libandroid-support.so to $MODPATH/system/lib/libandroid-support.so"
        cp -af $MODPATH/common/lib/arm/libandroid-support.so $MODPATH/system/lib/libandroid-support.so
        if [ "$IS64BIT" = true ]; then
            ui_print "+ Extracting libandroid-support.so (arm64) to $MODPATH/system/lib64/libandroid-support.so"
            cp -af $MODPATH/common/lib/arm64/libandroid-support.so $MODPATH/system/lib64/libandroid-support.so
        fi
        ;;
    x86)
        cp -af $MODPATH/common/lib/x86/libandroid-support.so $MODPATH/system/lib/libandroid-support.so
        if [ "$IS64BIT" = true ]; then
            ui_print "+ Extracting libandroid-support.so (x86_64) to $MODPATH/system/lib64/libandroid-support.so"
            cp -af $MODPATH/common/lib/x86_64/libandroid-support.so $MODPATH/system/lib64/libandroid-support.so
        fi
        ;;
esac
