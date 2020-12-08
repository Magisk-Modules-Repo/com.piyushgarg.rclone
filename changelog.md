# Changelog
## v1.9
* Add arm/arm64 1.51 bins downloaded from https://beta.rclone.org/
* Commented fusermount wrapper

## v1.5
* Add arm/arm64 1.48 bins compiled using Termux
* Add static arm64 `fusermount`
* Support for mounting to SD
* Squash missing rclone.conf install bug
* Tune default parameters
* Include a wrap for `rclone config`

## v1.4
* Add ability to disable a remote
* Add a wrapper script for rclone
* Make remount possible via `su --mount-master`

## v1.3
* Move user rclone.conf & related to /sdcard/.rclone/
* Control global --vfs-cache-mode via simple files placed in /sdcard/.rclone/
* Specify custom params for individual remotes via /sdcard/.rclone/.REMOTENAME.params

## v1.2
* Change install process
* Changes for full systemless
* Improve mount reliability
* Link to /storage/

## v1.1
* Initial release
* rclone mount
