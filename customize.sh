##########################################################################################
#
# MMT Extended Config Script
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maximum android version for your mod
# Uncomment DYNLIB if you want libs installed to vendor for oreo+ and system for anything older
# Uncomment DEBUG if you want full debug logs (saved to /sdcard)
#MINAPI=21
#MAXAPI=25
#DYNLIB=true

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
    set_perm $MODPATH/rclone 0 0 0755
    set_perm $MODPATH/system/bin/fusermount 0 0 0755
    set_perm $MODPATH/service.sh 0 0 0755
    set_perm $MODPATH/system/bin/rclone 0 0 0755
    set_perm $MODPATH/syncd.sh 0 0 0755
    set_perm $MODPATH/inotifywait 0 0 0555

    if [[ ! -e /system/bin/fusermount ]]; then
        cp -af $MODPATH/system/bin/fusermount /system/bin/fusermount
        set_perm /system/bin/fusermount 0 0 0755
    fi

    case $ARCH32 in
        arm)
            cp -af $MODPATH/system/lib/libandroid-support.so /system/lib/libandroid-support.so
            set_perm /system/lib/libandroid-support.so 0 0 0755
            if [ "$IS64BIT" = true ]; then
                cp -af $MODPATH/system/lib64/libandroid-support.so /system/lib64/libandroid-support.so
                set_perm /system/lib64/libandroid-support.so 0 0 0755
            fi
            ;;
        x86)
            cp -af $MODPATH/system/lib/libandroid-support.so /system/lib/libandroid-support.so
            set_perm /system/lib/libandroid-support.so 0 0 0755
            if [ "$IS64BIT" = true ]; then
                cp -af $MODPATH/system/lib64/libandroid-support.so $MODPATH/system/lib64/libandroid-support.so
                set_perm /system/lib64/libandroid-support.so 0 0 0755
            fi
            ;;
    esac

    if [[ -e /sdcard/.rclone/rclone.conf ]]; then
        export INTERACTIVE=1
        ui_print "+ Attempting to mount your [Remotes]:"
        ui_print "+ please wait..."
        ui_print ""
        MODDIR=$MODPATH $MODPATH/system/bin/rclone remount
    else
        ui_print "'/sdcard/.rclone/rclone.conf' not found!"
        ui_print
        ui_print "Additional setup required..."
        ui_print "------------------------------------"
        ui_print " Instructions:                      "
        ui_print " - Open Terminal                    "
        ui_print " - Type 'su' & tap enter            "
        ui_print " - Type 'rclone config' & tap enter "
        ui_print " - Follow on screen options.        "
        ui_print "------------------------------------"
    fi
}

##########################################################################################
# MMT Extended Logic - Don't modify anything after this
##########################################################################################

SKIPUNZIP=1
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh
