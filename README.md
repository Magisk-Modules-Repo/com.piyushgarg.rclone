# rclone-mount
rclone mount via magisk

# rclone mount for Android

A flexible rclone program for mounting multiple cloud storage providers using rclone mount. You will be able to expand your mobile storage to 100s of GB.

##Credits
- rclone
- pmj_pedro@xda
## Features
- arm and arm64 are supported.
- All binary files are downloaded from [https://rclone.org/downloads](https://rclone.org/downloads)
- Fusermount binary downloaded from [https://forum.xda-developers.com/android/development/fusermount-android-rclone-mount-t3866652](https://forum.xda-developers.com/android/development/fusermount-android-rclone-mount-t3866652) 
- All the applications can access /mnt/cloud mount points as long as there is option to set it somewhere.
- All file explorer applications work just fine.
- mpv (playstore) is best for playing audio and video files. Fast browsing and playing
- Dir caching is set 24h.
- Executing mounting scripts through other applications will be seen only by that application.
- Use adb shell only for executing mounting scripts.
## Installation
- Flash it via Magisk Manager App.
## Configuration (post-installing)
- Copy your rclone.conf file to to your /sdcard/rclone.conf location and restart. All your rclone mount points will be under /mnt/cloud/
- For more detailed configuration of rclone please refer to [official documentation](https://rclone.org)
### Auto mount
Just flash, reboot and enjoy!!
### Known Issues
- Mount points does not work on /sdcard/
- vlc is having issues and takes lot of time to open the media item, it opens the exiting files in write mode (both on desktop and android).
- Not responsilbe for any loss.
## Changelog
### v1.1
 - First version
 
