---
title: 'Preparing an Image'
date: 2019-02-11T19:27:37+10:00
draft: false
weight: 3
summary: Learn how to prepare a bootable, maintainable Ubuntu 18.04.3 (armhf) image for a Raspberry Pi 4.
---
# Preparing a Bootable Ubuntu 18.04.3 Image
N.B. the official Ubuntu supplied image is not RPi 4 compatible. We will take a copy of the current working firmware, take a copy of the Ubuntu pi3+ pre-installed server image and merge the two together.

We will be working on a 32-bit image (arch: armhf) as there are memory limitations on the 64-bit firmware code causing it to fail on boards with more than 1GB RAM configured.

Pi 4 firmware only supports booting from the microSD card at the time of writing (10-Aug-2019), so we will prepare a bootable image for a microSD card. With a single line change it can also be used to mount a USB3 drive as the root volume.

Retrieve current Pi4 compatible firmware as follows:

```bash
wget https://codeload.github.com/raspberrypi/firmware/zip/master
```

and the pre-installed Ubuntu rpi3 image:

```bash
wget http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.3-preinstalled-server-armhf+raspi3.img.xz
```

To prepare a bootable Pi 4 image, proceed as follows:

- Unzip the firmware zip file
- copy the image to another name:

```bash
unzip firmware-master.zip
cp ubuntu-18.04.3-preinstalled-server-armhf+raspi3.img.xz ubuntupi4.img.xz
```

- uncompress the image we'll work on:

```bash
unxz ubuntupi4.img.xz
```
- create loop devices for partitions in the image:

```bash
sudo kpartx -av ubuntupi4.img
```
- pay attention to the mapping devices created and mount the one for the first partition in the image (the first partition is the boot partition containing the firmware). N.B. the device has the prefix `/dev/mapper`:

```bash
sudo mount -o loop /dev/mapper/loop26p1 /mnt
```

- delete the contents of the firmware directory except for `cmdline.txt` and `config.txt` which should be preserved, and the contents of the overlay directory. Copy contents from `firmware-master/boot` to replace those in `/mnt` (don't forget to copy the contents of the overlay directory as well)
- Unmount the loopback drive, remove the device mappings and compress the image:

```bash
sync
sudo umount /mnt
sudo kpartx -d ubuntupi4.img
xz -vz ubuntupi4.img
```
- You know have a Pi 4 image suitable for flashing onto a microSD card. An excellent tool for doing this is [Balena Etcher](https://www.balena.io/etcher/).

You now have a bootable Ubuntu 18.04.3 image that will work with a Raspberry Pi 4, However to make this a stable and maintainable system you will need to do some additional work.

Rather than modify our base image, we use a [cloud-init](https://cloudinit.readthedocs.io/en/latest/topics/capabilities.html) strategy to allow us to bootstrap and further customize our installed image by performing tasks on first boot. For details, see our [cloud-init page](cloud-init.html).

## More on Kernel Boot Parameters
Kernel boot parameters are passed via the file `cmdline.txt` located on the boot partition.

The stock value for this (which assumes booting from and using the microSD card as the root volume) is as follows:

```
net.ifnames=0 dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait
```

When preparing a configuration to boot from microSD but use a USB3 drive as the root volume (for better performance and more storage) modify the `root=` parameter to `root=/dev/sda2` (assuming your root partition is the 2nd on the drive which will be the case if you use the image we prepared above). So the modified contents of `cmdline.txt` are:

```
net.ifnames=0 dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/sda2 rootfstype=ext4 elevator=deadline rootwait
```
