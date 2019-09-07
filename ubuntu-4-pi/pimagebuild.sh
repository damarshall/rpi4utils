# this is designed to be self-hosted, i.e. using a running arm64 pi4 to build an image

BASEDIR=`pwd`
TOOLCHAIN="$BASEDIR/toolchains/aarch64"

cd $BASEDIR

export KERNEL_VERSION=`cat ./rpi-linux/kernel-build/include/generated/utsrelease.h | sed -e 's/.*"\(.*\)".*/\1/'` 

# MOUNT IMAGE

echo "Kernel version: $KERNEL_VERSION"
echo "preparing RPi 4 image for kernel and firmware installation..."
xzcat ubuntu-18.04.3-preinstalled-server-arm64+raspi3.img.xz > ubuntu-18.04.3-preinstalled-server-arm64+raspi4.img
MountXZ=$(sudo kpartx -av ubuntu-18.04.3-preinstalled-server-arm64+raspi4.img)
MountXZ=$(echo "$MountXZ" | awk 'NR==1{ print $3 }')
MountXZ="${MountXZ%p1}"
echo "Using loop $MountXZ"

sudo mount /dev/mapper/"${MountXZ}"p2 /mnt
sudo rm -rf /mnt/boot/firmware/*
sudo mount /dev/mapper/"${MountXZ}"p1 /mnt/boot/firmware

sudo rm -rf /mnt/boot/firmware/*
sudo rm -rf /mnt/usr/src/*
sudo rm -rf /mnt/lib/modules/*

sudo rm -rf /mnt/boot/initrd*
sudo rm -rf /mnt/boot/config*
sudo rm -rf /mnt/boot/vmlinuz*
sudo rm -rf /mnt/boot/System.map*

sudo e4defrag /mnt/*

sudo cp -rvf bootfiles/* /mnt/boot/firmware
sudo mkdir /mnt/boot/firmware/overlays
sudo cp -vf rpi-linux/kernel-build/arch/arm64/boot/dts/broadcom/*.dtb /mnt/boot/firmware
sudo cp -vf rpi-linux/kernel-build/arch/arm64/boot/dts/overlays/*.dtb* /mnt/boot/firmware/overlays
sudo cp -vf rpi-linux/kernel-build/arch/arm64/boot/Image /mnt/boot/firmware/kernel8.img
sudo cp -vf rpi-tools/armstubs/armstub8-gic.bin /mnt/boot/firmware/armstub8-gic.bin

sudo cp -vf rpi-linux/kernel-build/vmlinux /mnt/boot/vmlinuz-"${KERNEL_VERSION}"
sudo cp -vf rpi-linux/kernel-build/arch/arm64/boot/Image /mnt/boot/initrd.img-"${KERNEL_VERSION}"
sudo cp -vf rpi-linux/kernel-build/System.map /mnt/boot/System.map-"${KERNEL_VERSION}"
sudo cp -vf rpi-linux/kernel-build/.config /mnt/boot/config-"${KERNEL_VERSION}"
sudo ln -s /mnt/boot/vmlinuz-"${KERNEL_VERSION}" /mnt/boot/vmlinuz
sudo ln -s /mnt/boot/initrd.img-"${KERNEL_VERSION}" /mnt/boot/initrd.img
# % Create symlinks to our custom kernel -- this allows initramfs to find our kernel and update modules successfully
sudo ln -s /mnt/boot/vmlinuz-"${KERNEL_VERSION}" /mnt/boot/vmlinuz
sudo ln -s /mnt/boot/initrd.img-"${KERNEL_VERSION}" /mnt/boot/initrd.img

sudo rm /mnt/var/lib/initramfs-tools/*
sha1sum=$(sha1sum  /mnt/boot/initrd.img-${KERNEL_VERSION})
echo "$sha1sum  /boot/vmlinuz-${KERNEL_VERSION}" | sudo -A tee -a /mnt/var/lib/initramfs-tools/"${KERNEL_VERSION}" >/dev/null;

sudo mkdir /mnt/lib/modules/${KERNEL_VERSION}
sudo cp -rvf rpi-linux/kernel-build/kernel-install/* /mnt

sudo rm -rf firmware-nonfree/.git
sudo cp -ravf firmware-nonfree/* /mnt/lib/firmware

sudo cp -vf rpi-linux/kernel-build/System.map /mnt/boot/firmware
sudo cp -vf rpi-linux/kernel-build/Module.symvers /mnt/boot/firmware
sudo cp -vf rpi-linux/kernel-build/.config /mnt/boot/firmware/config

sudo e4defrag /mnt/*

# QUIRKS

# % Fix WiFi
# % The Pi 4 version returns boardflags3=0x44200100
# % The Pi 3 version returns boardflags3=0x48200100cd
sudo sed -i "s:0x48200100:0x44200100:g" /mnt/lib/firmware/brcm/brcmfmac43455-sdio.txt

# % Remove flash-kernel hooks to prevent firmware updater from overriding our custom firmware
sudo rm -f /mnt/etc/kernel/postinst.d/zz-flash-kernel
sudo rm -f /mnt/etc/kernel/postrm.d/zz-flash-kernel
sudo rm -f /mnt/etc/initramfs/post-update.d/flash-kernel

# % Create symlink to fix Bluetooth firmware bug
sudo ln -s /mnt/lib/firmware /mnt/etc/firmware

# % Disable ib_iser iSCSI cloud module to prevent an error during systemd-modules-load at boot
#sudo sed -i "s/ib_iser/#ib_iser/g" /mnt/lib/modules-load.d/open-iscsi.conf
#sudo sed -i "s/iscsi_tcp/#iscsi_tcp/g" /mnt/lib/modules-load.d/open-iscsi.conf

# % Fix update-initramfs mdadm.conf warning
grep "ARRAY devices" /mnt/etc/mdadm/mdadm.conf >/dev/null || echo "ARRAY devices=/dev/sda" | sudo -A tee -a /mnt/etc/mdadm/mdadm.conf >/dev/null;

# CHROOT

#sudo cp extras/*.deb /mnt/
#sudo cp -f /usr/bin/qemu-aarch64-static /mnt/usr/bin

# % Install new kernel modules

#cat /run/systemd/resolve/stub-resolv.conf | sudo -A tee /mnt/run/systemd/resolve/stub-resolv.conf >/dev/null;
sudo touch /mnt/etc/modules-load.d/cups-filters.conf

sudo chroot /mnt /bin/bash

# % Add updated mesa repository for video driver support
add-apt-repository ppa:ubuntu-x-swat/updates -y

Version=$(ls /lib/modules | xargs)
echo "Kernel modules version: $Version"
depmod -a "$Version"

# % Update initramfs
apt-mark hold flash-kernel linux-raspi2 linux-image-raspi2 linux-headers-raspi2 linux-firmware-raspi2
update-initramfs -u

# % INSTALL HAVAGED - prevents low entropy from making the Pi take a long time to start up.
#dpkg -i libhavege1_1.9.1-6_arm64.deb
#dpkg -i haveged_1.9.1-6_arm64.deb
#rm -f *.deb

# % Remove ureadahead, does not support arm and makes our bootup unclean when checking systemd status
apt remove ureadahead libnih1 -y

# % Finished, exit
exit

# UNMOUNT AND SAVE CHANGES TO IMAGE

#sudo umount /mnt/boot/firmware
#sudo umount /mnt
#sudo kpartx -dv ubuntu-18.04.3-preinstalled-server-arm64+raspi4.img

echo "compressing 18.04.3 image so it's ready to flash..."
#xz -v ubuntu-18.04.3-preinstalled-server-arm64+raspi4.img
