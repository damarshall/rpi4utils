---
title: 'Preparing an Image'
date: 2020-03-24T19:27:37+10:00
draft: false
weight: 3
summary: Learn how to prepare a bootable, maintainable Ubuntu 18.04.3 (arm64) image with USB root for a Raspberry Pi 4.
---
## Build for Official RPi 4 ARM64 Ubuntu 18.04.4 server with USB Root
As of Feb-2020 a [pre-installed Bionic image](https://wiki.ubuntu.com/ARM/RaspberryPi) is available from Ubuntu, 
therefore this method supercedes the unofficial release method documented further down this page.

A Raspberry Pi 4 doesn't yet support USB booting, so we'll use a method where we boot the kernel from
an SD card but tell the kernel to use our USB drive for the root partition. This means we only use the
SD card as a bootstrap; subsequent I/O happens on the SSD drive used for root.

The official Ubuntu build uses the [U-Boot bootloader](https://www.denx.de/wiki/U-Boot). We will switch to the RPi bootloader
using the [method documented on the Ubuntu wiki](https://wiki.ubuntu.com/ARM/RaspberryPi#Change_the_bootloader).

This involves editing two files in the boot partition of the official image:
- `config.txt` - the master boot configuration (this is where we change from U-boot to the RPi bootloader)
- `nobtcmd.txt` - this is where we modify the kernel boot parameters, specifying a USB drive for root

The modified `config.txt` file looks like this:

```
[pi4]
kernel=vmlinuz
initramfs initrd.img followkernel
max_framebuffers=2

[pi2]
kernel=uboot_rpi_2.bin

[pi3]
kernel=uboot_rpi_3.bin

[all]
arm_64bit=1
#device_tree_address=0x03000000

# The following settings are "defaults" expected to be overridden by the
# included configuration. The only reason they are included is, again, to
# support old firmwares which don't understand the "include" command.

enable_uart=1
cmdline=nobtcmd.txt

include syscfg.txt
include usercfg.txt

```

and the corresponding modified `nobtcmd.txt` looks like this:

```
net.ifnames=0 dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/sda2 rootfstype=ext4 elevator=deadline rootwait fixrtc
```

If you plan on using [cloud-init bootstrapping](/docs/cloud-init/) you should also copy pre-prepared `cloud-init` files
into the `system-boot` partition on your prepared image (Ubuntu provides benign defaults in the pre-installed image
which you should override with your site specifics).

## Build for Unofficial RPi 4 ARM64 Ubuntu 18.04.3 server

This builds on the work of James Chambers and others begun in [this blog post](https://jamesachambers.com/raspberry-pi-4-ubuntu-server-desktop-18-04-3-image-unofficial/)
and codified at [https://github.com/TheRemote/Ubuntu-Server-raspi4-unofficial](https://github.com/TheRemote/Ubuntu-Server-raspi4-unofficial).

Mr. Chambers work, in turn, builds on [Sakaki's automated 64-bit bcm2711 kernel config and tweaks](https://github.com/sakaki-/bcm2711-kernel-bis).

The work consists of compiling and applying arm64 kernel, modules and RPi 4 firmware to a an official Ubuntu 18.04.3 
preinstalled server image for RPi3+, tweaking slightly, then repackaging as a Pi4-compatible pre-installed image.

This is a refactoring of that work, splitting one monolithic script into four distinct phases.
The original work was designed to only operate on a Raspberry Pi 3+ or 4, however with this refactoring
the first three phases can be run on any linux machine (tested on Ubuntu amd64) and only the final
phase with the `chroot` work must be run on a Pi.

There is an alternate fourth phase which will allow you to bootstrap a sub-optimal pi4 build so 
you can self-host and run the better 4th phase to produce a stable image.

There are a series of scripts in this directory, run them in the following sequence:

1. _toolchain.sh_ this will build an arm64 toolchain in the directory __toolchains__. This allows cross-compilation of an arm64 target on say X86 hardware
2. _kfetch.sh_ fetches firmware, linux kernel source (RPi version) and `rpi-tools`. This script also sets kernel compilation options above and beyond default __bcm2711_defconfig__, and pulls the preinstalled rpi3 arm64 ubuntu image from Canonical
3. _kbuild.sh_ compile the kernel and modules and prepare for installation
4. _pimagebuild.sh_ makes a copy of the rpi3 arm64 image from Canonical, mounts it and installs the kernel built by _kbuild.sh_ and firmware downloaded by _kfetch.sh_, `chroot`s into the image and updates __initramfs__ amongst other minor tweaks. This script must be run from a Pi4

As an alternative to step 4, if bootstrapping cross-architecture, _imagebuild.sh_ makes a copy of the rpi3 arm64 image from Canonical, mounts it and installs the kernel built by _kbuild.sh_ and firmware downloaded by _kfetch.sh_ but skips the final `chroot` work. This will be sufficient to bootstrap a Pi4 image where you can run _pimagebuild.sh_ to produce the desired stable image.

The directory __bootfiles__ contains Pi4 firmware, a _config.txt_ ([Pi4 firmware configuration](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md)), a _cmdline.txt_ ([linux kernel configuration](https://www.kernel.org/doc/html/v4.19/admin-guide/kernel-parameters.html)) for installation onto our image.

The script _clean.sh_ cleans (removes) built assets and downloaded software.

## Images

The images below are ready to flash onto a microSD card and optionally a USB3 drive:

- [Ubuntu-18.04.3-rpi4+arm64-sdcard-with-USB3-root-cloud-init-ready](https://cdn.vmsystems.net/images/ubuntu-18.04.3-preinstalled-server-arm64+raspi4-usb3root-20190922.img.xz)
