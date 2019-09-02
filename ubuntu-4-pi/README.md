## Build for Unofficial RPi 4 ARM64 Ubuntu 18.04.3 server

There are a series of scripts in this directory, run them in the following sequence:

1. `toolchain.sh` this will build an arm64 toolchain in the directory `toolchains`. This allows cross-compilation of an arm64 target on say X86 hardware
2. `kfetch.sh` fetches firmware, linux kernel source (RPi version) and rpi-tools. This script also sets kernel compilation options above and beyond default bcm2711_defconfig. This script also pulls the preinstalled rpi3 arm64 ubuntu image from Canonical
3. `kbuild.sh` compile the kernel and modules and prepare for installation
4. `imagebuild.sh` makes a copy of the rpi3 arm64 image from Canonical, mounts it and installs the kernel built by `kbuild.sh` and firmware downloaded by `kfetch.sh`

The directory `bootfiles` contains a `config.txt` and a `cmdline.txt` for installation onto our image.

The script `clean.sh` cleans built assets and downloaded software.