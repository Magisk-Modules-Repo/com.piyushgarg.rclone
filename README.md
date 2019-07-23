## rclone-mount for Android
---

Mount cloud storage locally via rclone & fusermount directly on your Android powered smart device. 

Now you can have virtually limitless storage expansion with support for dozens of cloud providers. Extremely useful for devices without physical storage expansion capabilities. Also great for streaming large media files without need for full caching. Binaries obtained directly from rclone.org. 

We are constantly striving to improve this project & make it the best. If you experience any issues or have suggestions please file them  [HERE](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues).

## Features

- Support for arm, arm64, & x86

- Huge list of supported cloud storage providers

- Apps with ability to specify paths can access /mnt/cloud

- Most file explorers work just fine ([issue #9](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/9))

- Executed mount scripts through other applications will be seen only by that application.

- Mount points use names of remote(s) in rclone.conf

- Specify custom rclone params for each remote via `/sdcard/.rclone/.REMOTENAME.param`

- Access remotes via [http://127.0.0.1:38762](http://127.0.0.1:38762)

- Access remotes via [ftp://127.0.0.1:38763](ftp://127.0.0.1:38763)

- Mount bind to `/sdcard` (see [ issue #5](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/5))

---
## Configuration (pre-installing)

1. Copy your `rclone.conf` file to `/sdcard/.rclone/rclone.conf` (not required)

2. Add custom params at `/sdcard/.rclone/.*.param` (if needed)

3. Install the module via Magisk Manager

4. Run `rclone config` if additional setup required 

4. All your rclone mount points will show up under `/mnt/cloud/` & `/storage/cloud` or `/sdcard/cloud`

For more detailed configuration of rclone please refer to [official documentation](https://rclone.org)

---
## Custom Params

- Specification of rclone parameters on a per remote basis can be created in 

    `/sdcard/.rclone/.*.param`- 

   Where `*` is replace with name of remote

- Parameters and their default values:

        BUFFERSIZE=0

        CACHEMAXSIZE=256M

        CACHEINFOAGE=2s

        DIRCACHETIME=1s

        ATTRTIMEOUT=1s

        READAHEAD=1s

        CACHEMODE=writes

        DISABLE=0

        READONLY=0

    **NOTE:** _There is no need to specify values you do not wish to change. The above are defaults for all remotes. For more information see [issue #2](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/2)_

---
## Custom Globals

- Specification of global rclone parameters can be created as files in 

      /sdcard/.rclone/`.*

   _Where `*` represents the global parm you wish to set_

       .bindsd

       .nocache
 
       .mincache

       .writecache

       .fullcache

       .disable

   **NOTE:** _Global parameters effect all remotes without `.*.parm` files specifying the changed parameters._
  </p> </details>

---
## Known Issues

- VLC  takes a long time to load media as it opens file in write mode when using it's internal browser. 

   a. Create remote type alias for media dirs in rclone.conf and specify `CACHEMODE=off` in `/sdcard/.rclone/.ALIASNAME.param`

- Encrypted devices can not mount until unlock

- Encrypted `rclone.conf` causes reboots

- High cpu/mem in some apps with storage perms ([issue #9](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/9))
- The `fusermount` bin may not be compatible on all devices (see  [thread](https://www.google.com/amp/s/forum.xda-developers.com/android/development/fusermount-android-rclone-mount-t3866652/amp/))

---
## Disclaimer

Neither the author nor developer's will be held responsible for any damage/data loss that may occur during use of this module. While we have done our best to make sure no harm will come about, no guarantees can be made. Keep in mind the binaries included in this project were originally intended to be ran on PCs which may cause unforseen issues.

---
## Credits

- rclone devs
- pmj_pedro@xda
- rclone binaries from [rclone.org](https://rclone.org/downloads)
- fusermount binaries from  [xda-devs](https://forum.xda-developers.com/android/development/fusermount-android-rclone-mount-t3866652)
- improvements geofferey@github

---
## Changelog

### v1.1
* Initial release
* rclone mount

### v1.2
* Change install process
* Changes for full systemless
* Improve mount reliability
* Symlink mountpoint to `/storage/`

### v1.3
* Move user rclone.conf & related to `/sdcard/.rclone/`
* Control global `--vfs-cache-mode` via simple files placed in `/sdcard/.rclone/`
* Specify custom params for individual remotes via `/sdcard/.rclone/.REMOTENAME.params`

### v1.4
* Add ability to disable a remote 
* Add a wrapper script for rclone
* Access remotes via http & ftp
* Use without rebooting device
* Add wrapper cmds to `rclone help`
* Make remount possible via `su -M -c`

### v1.5
* Add arm/arm64 1.48 bins compiled using Termux
* Support for mounting to SD
* Squash missing rclone.conf install bug
* Tune default parameters
* Include a wrap for `rclone config`
* General Improvements

[![HitCount](http://hits.dwyl.io/Magisk-Modules-Repo/compiyushgargrclone.svg)](http://hits.dwyl.io/Magisk-Modules-Repo/compiyushgargrclone)
