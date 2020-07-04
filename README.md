## Rclone Remount v1.8
---

Remount cloud storage locally during boot via rclone & fusermount directly on your Android powered smart device. 

Virtually limitless storage expansion with support for dozens of cloud providers including Dropbox, GDrive, OneDrive, SFTP & many more. Extremely useful for devices without physical storage expansion capabilities. Also great for streaming large media files without need for full caching.  Binaries compiled using Termux. 

We are constantly striving to improve this project & make it the best. If you experience any issues or have suggestions please file them  [HERE](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues). Contributions to this project are welcomed. 

## Features

- Support for arm, arm64, ~~& x86~~

- Huge list of supported cloud storage providers

- Apps with ability to specify paths can access `/mnt/cloud/`

- Most file explorers work just fine ([issue #9](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/9))

- Mount points use names of remote(s) in rclone.conf

- Specify custom rclone params for each remote via `/sdcard/.rclone/.REMOTE.param`

- Access remotes via [http://127.0.0.1:38762](http://127.0.0.1:38762)

- Access remotes via [ftp://127.0.0.1:38763](ftp://127.0.0.1:38763)

- Mount bind to `/sdcard/` (see [ issue #5](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/5))

- Support for Work Profiles 

---
## Configuration (pre-installing)

1. Copy your `rclone.conf` file to `/sdcard/.rclone/rclone.conf` (not required)

2. Add custom params at `/sdcard/.rclone/.*.param` (if needed)

3. Install the module via Magisk Manager

4. Run `rclone config` via term if additional setup required 

4. All your rclone mount points will show up under `/mnt/cloud/` & `/storage/cloud/` or `/sdcard/cloud/`

For more detailed configuration of rclone please refer to [official documentation](https://rclone.org)

---
## Custom Params
Custom params have been created as a means for users to adjust this modules default parameters which are set for all remotes inside your rclone.conf. 

Specification of rclone parameters on a per remote basis can be created inside hidden files ending with the `.param` extension

      /sdcard/.rclone/.*.param

   Where `*` is replaced with the name of remote

- Custom parameters, their default values & rclone params they represent in `( )`

        LOGFILE=/sdcard/.rclone/rclone.log  ( --log-file )

        LOGLEVEL=NOTICE  ( --log-level )

        CACHEMODE=off  ( --vfs-cache-mode )

        CHUNKSIZE=1M  ( --cache-chunk-size )

        CHUNKTOTAL=1G  ( --cache-chunk-total-size )

        READCHUNKSIZE=1M  ( --vfs-read-chunk-size )

        CACHEWORKERS=1 ( --cache-workers )

        CACHEINFOAGE=1h0m0s  ( --cache-info-age )

        DIRCACHETIME=30m0s  ( --dir-cache-time )

        ATTRTIMEOUT=30s  ( --attr-timeout)

        BUFFERSIZE=0  ( --buffer-size )

        READAHEAD=128k  ( --max-read-ahead )

        M_UID=0  ( --uid )

        M_GID=1015  ( --gid )

        DIRPERMS=0775  ( --dir-perms )

        FILEPERMS=0644  ( --file-perms )

        UMASK=002  ( --umask )

        BINDSD=0  ( default binds remote to /sdcard/Cloud/* )

        SDBINDPOINT=  ( relative to /storage/emulated/0)

        SDSYNCDIRS= (relative to /storage/emulated/0)

        ADD_PARAMS=0

        REPLACE_PARAMS=0

        PROFILE=0

   **NOTE:** _The above are defaults for all remotes without `.*.param` files containing opposing values. 

- Custom remote params example #1

   _The following configuration will disable caching for remote `[Movies]`, bind to `/sdcard/Movies` & add the `-fast-list`/`--allow-non-empty` flags to it's mounting command._

         /sdcard/.rclone/.Movies.param

         1| CACHEMODE=off
         2| BINDSD=1
         3| SDBINDPOINT=Movies
         4| ADD_PARAMS=--fast-list --allow-non-empty
         5| 

    **NOTE:** _There is no need to specify values you do not wish to change. Ensure a line break/carriage return exist after each specified param or they will not be parsed. For more information see [issue #2](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/2)_

---
## Custom Globals

Specification of global rclone parameters can be created in

      /sdcard/.rclone/.global.param

- Global Specific Parameters

        NETCHK=1

        NETCHK_ADDR=google.com

        NETCHK_IF=

        HTTP=1

        HTTP_ADDR=127.0.0.1:38762

        FTP=1

        FTP_ADDR=127.0.0.1:38763

- Excluded Parameters

        SDBINDPOINT=
        SDSYNCDIRS=

- Custom globals params example #1

  _The following configuration will enable minimal caching for all remotes, bind to `/sdcard/Cloud/*`, disable HTTP/FTP & add the `--fast-list`/`--allow-non-empty` flags to their mounting command(s)._

         /sdcard/.rclone/.global.param

         1| CACHEMODE=minimal
         2| BINDSD=1
         3| ADD_PARAMS=--fast-list --allow-non-empty
         4| HTTP=0
         5| FTP=0
         6| 

   **NOTE:** _Global parameters effect all remotes without `.*.parm` files containing opposing values. Some parameters are specific to globals while others have been excluded._

---
## Replacing & Adding Params 

In order for users to  appropriately utilize  `ADD_PARAMS=` or `REPLACE_PARAMS=` they will need a little background on the parameters that are set by default. 

- Currently specified params shown here ↓

  (directly from service.sh):

  `RCLONE_PARAMS=" --log-file ${LOGFILE} --log-level ${LOGLEVEL} --vfs-cache-mode ${CACHEMODE} --cache-dir ${CACHE} --cache-chunk-path ${CACHE_BACKEND} --cache-db-path ${CACHE_BACKEND} --cache-tmp-upload-path ${CACHE} --vfs-read-chunk-size ${READCHUNKSIZE} --vfs-cache-max-size ${CACHEMAXSIZE} --cache-chunk-size ${CHUNKSIZE} --cache-chunk-total-size ${CHUNKTOTAL} --cache-workers ${CACHEWORKERS} --cache-info-age ${CACHEINFOAGE} --dir-cache-time ${DIRCACHETIME} --attr-timeout ${ATTRTIMEOUT} --cache-chunk-no-memory --use-mmap --buffer-size ${BUFFERSIZE} --max-read-ahead ${READAHEAD} --no-modtime --no-checksum --uid ${M_UID} --gid ${M_GID} --allow-other --dir-perms ${DIRPERMS} --file-perms ${FILEPERMS} --umask ${UMASK} ${READONLY} ${ADD_PARAMS} "`

                                ^

    **NOTE:** _When using the `ADD_PARAMS=` it will append any additonal params you wish to specify at the point of `${ADD_PARAMS}` (above) in a fill in the blank manner._

- The script then takes `RCLONE_PARAMS=` and fills in blank at `${RCLONE_PARAMS}`

  `rclone mount ${remote}: ${CLOUDROOTMOUNTPOINT}/${remote} --config ${CONFIGFILE} ${RCLONE_PARAMS} --daemon &`

  **NOTE:** _Everything before and after `${RCLONE_PARAMS}` cannot not be replaced even with `REPLACE_PARAMS=` specified._

- When using `REPLACE_PARAMS=` `RCLONE_PARAMS=` becomes `RCLONE_PARAMS=" ${REPLACE_PARAMS} "`

---
## Work Profiles & Users

As of `v1.8` support for isolating & binding to work profiles or additional users has been included which may provide for some interesting use cases. 

When adding work profiles through sandboxing apps such as [Island](https://play.google.com/store/apps/details?id=com.oasisfeng.island) or [Shelter](https://play.google.com/store/apps/details?id=net.typeblog.shelter) it will create a virtual SD for your sandboxed apps. This virtual SD can now be used with rclone remount. 

- Work profile example #1 (Cloud Camera w/ Shelter)

        open Shelter > find camera > clone to work profile

        /sdcard/.rclone/.cloud-DCIM.param

        1| BINDSD=1
        2| SDBINDPOINT=DCIM
        3| PROFILE=10
        4| ISOLATE=1
        5| CACHEMODE=writes
        6| 

   **NOTE:** _Virtual SDs for work profiles & or additional users start at `/storage/emulated/`**10**. Additional profiles increase the ending directory integer (e.g. `/storage/emulated/`**11**). This integer is used with `PROFILE=`_
---
## SD Sync & Remotes

- SD sync example # 1

         /sdcard/.rclone/.Backup.param

         1| SDSYNCDIRS=DCIM/Camera:Photos:My Projects
         2| CACHEMODE=writes
         3| CACHEINFOAGE=11s
         4| DIRCACHETIME=10s
         5| ATTRTIMEOUT=10s
         6| 

  **NOTE:** _`SDSYNCDIRS=` paths are relative to /storage/emulated/`PROFILE=0`. Paths are to be separated using a `: `. This variable is should be whitespace friendly._
---
## Known Issues

- VLC  takes a long time to load media as it opens file in write mode when using it's internal browser. 

   a. Create remote type alias for media dirs in rclone.conf and 
specify `CACHEMODE=off` in `/sdcard/.rclone/.ALIASNAME.param`

- Encrypted devices can not mount until unlock

- Encrypted `rclone.conf` causes reboots

- High cpu/mem in some apps with storage perms ([issue #9](https://github.com/Magisk-Modules-Repo/com.piyushgarg.rclone/issues/9))
- The `fusermount` bin may not be compatible on all devices (see  [thread](https://www.google.com/amp/s/forum.xda-developers.com/android/development/fusermount-android-rclone-mount-t3866652/amp/))

---
## Disclaimer

Neither the author nor developer's will be held responsible for any damage/data loss that may occur during use of this module. While we have done our best to make sure no harm will come about, no guarantees can be made. Keep in mind the binaries included in this project were originally intended to be ran on PCs which may cause unforseen issues. Always check this document before updating to new releases as significant changes may occur. 

---
## Credits

- rclone devs
- pmj_pedro[@xda](https://forum.xda-developers.com/showpost.php?p=78147335&postcount=1)
- agnostic-apollo[@xda](https://forum.xda-developers.com/showpost.php?p=79929083&postcount=12)
- rclone binaries from [rclone.org](https://rclone.org/downloads)
- fusermount binaries from  [xda-devs](https://forum.xda-developers.com/android/development/fusermount-android-rclone-mount-t3866652)
- improvements geofferey@github

---
## Changelog

## v1.12
* Fixed restart problems.

## v1.11
* Add arm/arm64 1.52 bins downloaded from https://beta.rclone.org/v1.52.0/testbuilds/rclone-android-16-arm.gz
* Fixed service.sh paths

## v1.10
* fixed fusermount wrapper

## v1.9
* Add arm/arm64 1.51 bins downloaded from https://beta.rclone.org/
* Commented fusermount wrapper

### v1.8
* Support for Work Profiles `PROFILE=`
* Isolate to Work Profiles `ISOLATE=1`
* Support syncing from SD to remote 

### v1.7
* Add ability to disable HTTP/FTP
* Link rest of default params to custom vars
* Exclude some custom params from globals
* Make some globals exclusive 
* Change `BINDPOINT=` to `SDBINDPOINT=`
* Fix bug with custom params
* Set `PATH=` to change priority of used bins

### v1.6
* Simplify custom global parameters
* Fix & improve binding to SD
* Specify additional  rclone ops with `ADD_PARAMS=`
* Replace `rclone mount` ops via `REPLACE_PARAMS=`

### v1.5
* Replace arm/arm64  `rclone` 1.48 bins built with Termux
* Replace arm/arm64 `fusermount` built with Termux
* Add arm/arm64 `libandroid-support.so` from Termux
* Support for mounting to SD
* Squash missing rclone.conf install bug
* Tune default parameters
* Include a wrap for `rclone config`
* Include `fusermount-wrapper.sh`
* General Improvements

### v1.4
* Add ability to disable a remote 
* Add a wrapper script for rclone
* Access remotes via http & ftp
* Use without rebooting device
* Add wrapper cmds to `rclone help`
* Make remount possible via `su -M -c`

### v1.3
* Move user rclone.conf & related to `/sdcard/.rclone/`
* Control global `--vfs-cache-mode` via simple files placed in `/sdcard/.rclone/`
* Specify custom params for individual remotes via `/sdcard/.rclone/.REMOTENAME.params`

### v1.2
* Change install process
* Changes for full systemless
* Improve mount reliability
* Symlink mountpoint to `/storage/`

### v1.1
* Initial release
* rclone mount

[![HitCount](http://hits.dwyl.io/Magisk-Modules-Repo/compiyushgargrclone.svg)](http://hits.dwyl.io/Magisk-Modules-Repo/compiyushgargrclone)
