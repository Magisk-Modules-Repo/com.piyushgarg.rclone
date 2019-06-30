## rclone-mount for Android

![Hits](https://hitcounter.pythonanywhere.com/count/tag.svg?url=https%3A%2F%2Fgithub.com%2FMagisk-Modules-Repo%2Fcom.piyushgarg.rclone)
---

Mount cloud storage locally via rclone & fusermount directly on your Android powered smart device. 

Now you can have virtually limitless storage expansion with support for dozens of cloud providers. Extremely useful for devices without physical storage expansion capabilities & streaming large media files without need for full caching. Binaries obtained directly from rclone.org. 

---
## Features
- Support for arm, arm64, & x86

- Huge list of supported cloud storage providers

- Applications with ability to specify paths can access /mnt/cloud

- Most file explorers work just fine

- mpv (playstore) is best for playing audio and video files. Fast browsing and quick playing.

- Default dir caching set to 24h

- Executed mount scripts through other applications will be seen only by that application.

- Use adb shell only for executing mounting scripts so that all applications can see the mount points

- Mount points use names of remote(s) in rclone.conf

- Specify custom rclone params for each remote via `/sdcard/.rclone/.REMOTENAME.param`

## Configuration (post-installing)

1. Copy your rclone.conf file to `/sdcard/.rclone/rclone.conf`

2. Add custom params at `/sdcard/.rclone/.*.params`

3. Reboot or run `rclone-mount` from terminal

4. All your rclone mount points will show up under `/mnt/cloud/` & `/storage/cloud`

For more detailed configuration of rclone please refer to [official documentation](https://rclone.org)

## Custom Params

- Specification of rclone parameters on a per remote basis can be created in 

    `/sdcard/.rclone/.*.param`

   Where `*` is replace with name of remote



- List of available parameters and their default values:
  
      There is no need to specify values you do not wish to change.

        BUFFERSIZE=8M

        CACHEMAXSIZE=256M

        DIRCACHETIME=24h

        READAHEAD=128k

        CACHEMODE=writes

        CACHE=/data/rclone/cache

        CACHE_BACKEND=/data/rclone/cache-backend

## Known Issues

- VLC  takes a long time to load media as it opens file in write mode when using it's internal browser. 

    Create remote type alias for media dirs in rclone.conf and specify `CACHEMODE=off` in `/sdcard/.rclone/.ALIASNAME.param`

- Mount point can not be placed in `/sdcard/`

- Can not mount remotes until device is unlocked 

- Not responsilbe for any loss.

## Credits

- rclone devs
- pmj_pedro@xda
- rclone binaries from [rclone.org](https://rclone.org/downloads)
- fusermount binaries from  [xda-devs](https://forum.xda-developers.com/android/development/fusermount-android-rclone-mount-t3866652)

## Changelog

### v1.1
* Initial release
* rclone mount

### v1.2
* Change install process
* Changes for full systemless
* Improve mount reliability
* Symlink mountpoint to /storage/

### v1.3
* Move user rclone.conf & related to /sdcard/.rclone/
* Control global --vfs-cache-mode via simple files placed in /sdcard/.rclone/
* Specify custom params for individual remotes via /sdcard/.rclone/.REMOTENAME.params

 
