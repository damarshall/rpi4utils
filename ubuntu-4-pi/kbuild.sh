BASEDIR=`pwd`
TOOLCHAIN="$BASEDIR/toolchains/aarch64"

cd $BASEDIR/rpi-linux

PATH=$PATH:$TOOLCHAIN/bin make O=./kernel-build/ ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-  bcm2711_defconfig
cd kernel-build
# % Get conform_config.sh from sakaki-'s prebuilt 64 bit Raspberry Pi kernel modifications - https://github.com/sakaki-/bcm2711-kernel-bis
rm -f conform_config.sh
wget https://raw.githubusercontent.com/sakaki-/bcm2711-kernel-bis/master/conform_config.sh
chmod +x conform_config.sh
./conform_config.sh
rm conform_config.sh
cd ..
PATH=$PATH:$TOOLCHAIN/bin make -j4 O=./kernel-build/ ARCH=arm64  DTC_FLAGS="-@ -H epapr" CROSS_COMPILE=aarch64-linux-gnu- 
export KERNEL_VERSION=`cat ./kernel-build/include/generated/utsrelease.h | sed -e 's/.*"\(.*\)".*/\1/'` 
make -j4 O=./kernel-build/ DEPMOD=echo MODLIB=./kernel-install/lib/modules/${KERNEL_VERSION} INSTALL_FW_PATH=./kernel-install/lib/firmware modules_install
sudo depmod --basedir kernel-build/kernel-install "$KERNEL_VERSION"
cd $BASEDIR
