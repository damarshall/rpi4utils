# fetch kernel, rpi-tools, firmware and pre-installed rpi3 image


BASEDIR=~/ubuntu-4-pi
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
sudo mount /dev/mapper/"${MountXZ}"p1 /mnt/boot/firmware

sudo rm -rf /mnt/var/cache/apt/*
sudo rm -rf /mnt/var/cache/man/*
sudo rm -rf /mnt/var/log/*
sudo rm -rf /mnt/run/*
sudo rm -rf /mnt/boot/firmware/*
sudo rm -rf /mnt/usr/src/*
sudo rm -rf /mnt/lib/modules/*

sudo e4defrag /mnt/*

sudo cp -rvf bootfiles/* /mnt/boot/firmware
sudo cp -vf  firmware-master/boot/start4*.elf /mnt/boot/firmware
sudo mkdir /mnt/boot/firmware/overlays
sudo cp -vf rpi-linux/kernel-build/arch/arm64/boot/dts/broadcom/*.dtb /mnt/boot/firmware
sudo cp -vf rpi-linux/kernel-build/arch/arm64/boot/dts/overlays/*.dtb* /mnt/boot/firmware/overlays
sudo cp -vf rpi-linux/kernel-build/arch/arm64/boot/Image /mnt/boot/firmware/kernel8.img
sudo cp -vf rpi-tools/armstubs/armstub8-gic.bin /mnt/boot/firmware/armstub8-gic.bin

sudo mkdir /mnt/lib/modules/"${KERNEL_VERSION}"
sudo cp -ravf rpi-linux/kernel-build/kernel-install/lib/modules/"${KERNEL_VERSION}" /mnt/lib/modules

sudo rm -rf firmware-nonfree/.git
sudo cp -ravf firmware-nonfree/* /mnt/lib/firmware

sudo cp -vf rpi-linux/kernel-build/System.map /mnt/boot/firmware
sudo cp -vf rpi-linux/kernel-build/Module.symvers /mnt/boot/firmware

sudo e4defrag /mnt/*

# QUIRKS

# % Fix WiFi
# % The Pi 4 version returns boardflags3=0x44200100
# % The Pi 3 version returns boardflags3=0x48200100
sudo sed -i "s:0x48200100:0x44200100:g" /mnt/lib/firmware/brcm/brcmfmac43455-sdio.txt

# % Hold kernel packages until official support is released in the apt repository -- otherwise Ubuntu will replace our firmware with firmware that lacks Pi 4 support
#sudo sed -i "s/Package: linux-raspi2\nStatus: install ok installed/Package: linux-raspi2\nStatus: hold ok installed/g" /mnt/var/lib/dpkg/status
#sudo sed -i "s/Package: linux-image-raspi2\nStatus: install ok installed/Package: linux-image-raspi2\nStatus: hold ok installed/g" /mnt/var/lib/dpkg/status
#sudo sed -i "s/Package: linux-headers-raspi2\nStatus: install ok installed/Package: linux-headers-raspi2\nStatus: hold ok installed/g" /mnt/var/lib/dpkg/status

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

# UNMOUNT AND SAVE CHANGES TO IMAGE

sudo umount /mnt/boot/firmware
sudo umount /mnt
sudo kpartx -dv ubuntu-18.04.3-preinstalled-server-arm64+raspi4.img

echo "compressing 18.04.3 image so it's ready to flash..."
xz -v ubuntu-18.04.3-preinstalled-server-arm64+raspi4.img
