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

- [Ubuntu-18.04.3-rpi4+arm64-sdcard-with-USB3-root-cloud-init-ready](https://rpi4utils.s3.amazonaws.com/images/ubuntu-18.04.3-preinstalled-server-arm64%2Braspi4-usb3root-20190922.img.xz)
