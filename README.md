ReMarkable 2 tools
==================

This is a umbrella project containing author's [Nix](http://www.nixos.org) build
expressions for various [Remarkable2 tablet](https://remarkable.com/store/remarkable-2) software.

What works and what doesn't
---------------------------

* [x] SSH connectivity systemd service.
* [x] Host-device library folder synchronisation using `rsync`.
* [x] Importing PDF documents to the library.
* [ ] Exporting documents from the library (`rm2svg` seems to be broken)
* [x] RM2 stylus capturing using `remarkable_mouse`.

Contents
--------

<!-- vim-markdown-toc GFM -->

* [Usage](#usage)
  * [Using the Environment](#using-the-environment)
  * [Establishing wireless SSH connection](#establishing-wireless-ssh-connection)
  * [Accessing Remarkable PDFs from Host](#accessing-remarkable-pdfs-from-host)
  * [Linking the pointer with the Host mouse cursor](#linking-the-pointer-with-the-host-mouse-cursor)
* [Various low-level actions](#various-low-level-actions)
  * [Enabling the older SSH key format support.](#enabling-the-older-ssh-key-format-support)
  * [Setting up the Host IP to connect via the USB cable](#setting-up-the-host-ip-to-connect-via-the-usb-cable)
  * [Manually syncing the xochitl](#manually-syncing-the-xochitl)
* [Resources](#resources)
  * [General](#general)
  * [Synchronization](#synchronization)
  * [Screen sharing](#screen-sharing)
  * [Other projects](#other-projects)

<!-- vim-markdown-toc -->


Usage
-----

### Using the Environment

The environment is defined in [Nix](https://nixos.org/nix) language in the
[default.nix](./default.nix) file which depends on a Nixpkgs as described in
[flake.nix](./flake.nix).

To enter the Nix development shell, type:

```sh
$ export NIXPKGS_ALLOW_INSECURE=1 # needed to allow the buggy xpdf dependency
$ nix develop --impure # Impure is needed for Nix to notice the above variable
```

To build a specific rule (e.g. `rmsynctools_def`):

```sh
$ nix build '.#rmsynctools_def' --impure
```

### Establishing wireless SSH connection

To enable SSH access to the Remarkable tablet we rely on a third-party server
with a public IP address (the VPS). We use
[rmssh-install](./sh/rmssh-install.sh) to setup a Systemd service on the device
and to send the necessary SSH keys to the VPS. The tablet then maintains a
connection to the VPS by keeping certain ports opened so the users can establish
a wireless connection to the tablet using VPS as a relay.

Given the successful installation, one can run the `rmssh` script in order to
reach the tablet without connecting its USB cable.

```sh
$ rmssh remarkable
```

### Accessing Remarkable PDFs from Host

This repository includes a set of shell-scripts based on the [Dr Fraga's
approach](https://www.ucl.ac.uk/~ucecesf/remarkable/) of accessing Remarkable
data. In contrast to the Dr.Fraga's approach, we use `rsync` rather then
`sshfuse` to manage the data transfer.

The generic workflow is shown below.

1. Adjust the [rmcommon](./sh/rmcommon) that defines the main configuration
   environment variables.
2. Optionally run the [rmssh-install](./sh/rmssh-install.sh) to install the
   systemd rule to the RM2 tables and to send the SSH key to a third-party VPS
   server with the public IP as configured by configuration variables. If you
   don't have one, you can still default to a wired SSH connection via the USB
   cable. This step typically has to be performed once after every RM2 software
   update.
3. Run the [rmpull](./sh/rmpull) to pull the `xochitl` from the tablet.
   `rmpull` removes all extra files on the Host that don't present on the
   tablet.
4. Modify the Host-version of `xochitl`, such as:
   - [rmls](./sh/rmls) Lists the folder's content
   - [rmfind](./sh/rmfind) Gets the document UUID by name
   - [rmconvert](./3rdparty/fraga/rmconvert) of Dr.Fraga builds the
     annotated PDF by UUID.
     + Currently, getting annotaded documents doesn't rely on the Remarkable
       web-server.  Unfortunately, `rmconvert` is pretty slow and has some
       issues with SVG graphics in PDF documents.
   - [rmadd](./sh/rmadd) adds new document
5. [rmpush](./sh/rmpush) pushes Host's `xochitl` back to the
   device. `rmpush` doesn't remove anything from the table. Use the tablet
   GUI for the removal.


### Linking the pointer with the Host mouse cursor

Connect the device to Host and do the following

```sh
$ echo 'password' >_pass.txt
$ ./runmouse.sh
```

Issues:

* ~~https://github.com/Evidlo/remarkable_mouse/issues/63~~
  + Specifying --password seems to have no effect (Fixed)

Various low-level actions
-------------------------

### Enabling the older SSH key format support.

In the Host's Nix configuration:

```nix
{
#...
  programs.ssh = let
    algos = ["+ssh-rsa"];
  in {
    hostKeyAlgorithms = algos;
    pubkeyAcceptedKeyTypes = algos;
  };
#...
}
```

### Setting up the Host IP to connect via the USB cable

```sh
$ sudo ifconfig enp3s0u1 10.11.99.2 netmask 255.255.255.0
```

.. or set up NetworkManager to automatically assign IP address


### Manually syncing the xochitl

Remarkable->Host transfer with deletion (remove --dry-run)

```sh
$ rsync -i -avP --dry-run --delete -e ssh remarkable:/home/root/.local/share/remarkable/xochitl/ _xochitl/
```

Host->Remarkable transfer without deletion (remove --dry-run)

```sh
$ rsync -i -avP --no-owner --no-group --dry-run -e ssh _xochitl/ remarkable:/home/root/.local/share/remarkable/xochitl/
```

Resources
---------

### General

* RemarkableWiki https://remarkablewiki.com/tips/start
  - SSH key issues https://remarkablewiki.com/tech/ssh on modern hardware
* reHackable https://github.com/reHackable/awesome-reMarkable
* Reddit
  - https://www.reddit.com/r/RemarkableTablet/comments/ickcu5/we_need_split_screen_for_the_rm2/
* reMarkable directory structure
  - https://remarkablewiki.com/tech/filesystem

### Synchronization

- Remarkable CLI tooling https://github.com/cherti/remarkable-cli-tooling
  + Could be up-to-date; More or less works
  + Couldn't remove file from remarkable
  + Sent Pull request and filed an issue
    * https://github.com/cherti/remarkable-cli-tooling/issues/5
- Prof. Fraga's page on remarkable with lots of useful scripts
  https://www.ucl.ac.uk/~ucecesf/remarkable/
  + [rm2pdf.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/pdf2rm.sh)
  + [rmlist.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/rmlist.sh)
  + [rmconvert.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/rmconvert.sh)
- https://github.com/simonschllng/rm-sync
  + Written in pure Shell curl calls are commented-out
  + Seems to be a local script, incomplete
- https://github.com/lschwetlick/rMsync
  + Another script, this time in Python
  + Needs `rm_tools`
  + Needs deprecated scripts
- https://github.com/nick8325/remarkable-fs
  + FUSE, Seems to work without the cloud
  + 5 years old
- https://github.com/rschroll/rmfuse
  + Fuse between local folder and the cloud
  + Requires `rmcl` and `rmrl`
  + Not working anymore
- Syncthing https://github.com/evidlo/remarkable_syncthing
  + Requires Entware
- https://github.com/codetist/remarkable2-cloudsync
  + A script which uses `Rclone` binary.
- Remi https://github.com/bordaigorl/remy
  + GUI, seems to be up to date.
  + Not checked.

### Screen sharing

* reMarkable mouse
  - https://github.com/evidlo/remarkable_mouse
  - https://github.com/kevinconway/remouseable
* [reStream](https://github.com/rien/reStream)

### Other projects

* [SSH access and backups](https://remarkablewiki.com/tech/ssh#ssh_access)
* [Entware](https://github.com/evidlo/remarkable_entware)
* `Rm_tools` https://github.com/lschwetlick/maxio/tree/master/rm_tools
* [Some nix expressions](https://github.com/siraben/nix-remarkable)
* [Receive files from Telegram](https://github.com/Davide95/remarkaBot)
  - Needs rebooting after the file is received
* [Patched xochitl, gestures](https://github.com/ddvk/remarkable-hacks)
  - Does not support newer versions (mine is `>3.0`)


