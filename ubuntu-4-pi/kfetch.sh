BASEDIR=`pwd`
TOOLCHAIN="$BASEDIR/toolchains/aarch64"

# BUILD RPI TOOLS FOR ARMSTUB8

cd $BASEDIR
git clone https://github.com/raspberrypi/tools.git rpi-tools
cd rpi-tools/armstubs
git checkout 7f4a937e1bacbc111a22552169bc890b4bb26a94
PATH=$PATH:$TOOLCHAIN/bin make armstub8-gic.bin

# GET FIRMWARE NON-FREE

cd $BASEDIR
git clone https://github.com/RPi-Distro/firmware-nonfree firmware-nonfree

# get current firmware so we can include start*.elf in the image
wget https://github.com/raspberrypi/firmware/archive/master.zip

# unzip into $BASDIR/firmware-master
unzip master.zip

# get pre-installed Ubuntu 18.04.3 for rpi3 arm64
wget http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.3-preinstalled-server-arm64+raspi3.img.xz

# Fetch kernel source

cd $BASEDIR
git clone https://github.com/raspberrypi/linux.git rpi-linux
cd rpi-linux
git checkout origin/rpi-4.19.y # change the branch name for newer versions
mkdir kernel-build

# configure ISCSI target modules
echo "CONFIG_ISCSI_TARGET=m" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_TARGET_CORE=m" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_TCM_IBLOCK=m" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_TCM_FILEO=m" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_TCM_PSCSI=m" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_TCM_USER2=m" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_LOOPBACK_TARGET=m" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_SBP_TARGET=m" >> arch/arm64/configs/bcm2711_defconfig

# configure MMC/SD/SDIO options to match Ubuntu

echo "CONFIG_MMC_BLOCK=y" >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_MMC_BCM2835_PIO_DMA_BARRIER=2"  >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_MMC_ARMMMCI=y"  >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_MMC_SDHCI_IO_ACCESSORS=y"  >> arch/arm64/configs/bcm2711_defconfig
echo "CONFIG_SDIo_UART=m" >> arch/arm64/configs/bcm2711_defconfig
