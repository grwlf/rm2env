About
-----

This repo contains a [Nix](http://www.nixos.org) environment for Remarkable 2
tablet device.

Usage
-----

### Nix-shell

```sh
$ nix-shell -A shell
```

### Remarkable mouse

```sh
$ echo 'password' >_pass.txt
$ ./runmouse.sh
```

### RMfuse

```sh
$ nix-build -A rmfuse
$ mkdir _remarkable
$ ./result/bin/rmfuse -v _remarkable
```


ReMarkable2 links
-----------------

### General

* RemarkableWiki https://remarkablewiki.com/tips/start
  - SSH key issues https://remarkablewiki.com/tech/ssh on modern hardware
* reHackable https://github.com/reHackable/awesome-reMarkable
* Reddit
  - https://www.reddit.com/r/RemarkableTablet/comments/ickcu5/we_need_split_screen_for_the_rm2/

### Topics

* SSH access and backups https://remarkablewiki.com/tech/ssh#ssh_access
* Entware https://github.com/evidlo/remarkable_entware
* `Rm_tools` https://github.com/lschwetlick/maxio/tree/master/rm_tools

* Some nix expressions https://github.com/siraben/nix-remarkable

* remarkable mouse
  - https://github.com/evidlo/remarkable_mouse
  - https://github.com/kevinconway/remouseable

* Sync approaches:
  - https://github.com/simonschllng/rm-sync
    + Seems to be a local script, incomplete
  - https://github.com/lschwetlick/rMsync
    + Another script, this time in Python
    + Needs `rm_tools`
  - https://github.com/nick8325/remarkable-fs
    + FUSE, Seems to work without the cloud
  - https://github.com/rschroll/rmfuse
    + Fuse between local folder and the cloud
    + Requires `rmcl` and `rmrl`
  - Syncthing https://github.com/evidlo/remarkable_syncthing
    + Requires Entware
  - https://github.com/codetist/remarkable2-cloudsync
    + A script which uses `Rclone` binary.


Issues
------

### Rmcl

* https://github.com/rschroll/rmcl/issues/1

### Remouse

* ~~https://github.com/Evidlo/remarkable_mouse/issues/63~~
  + Specifying --password seems to have no effect

