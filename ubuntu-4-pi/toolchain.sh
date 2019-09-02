sudo apt-get install build-essential libgmp-dev libmpfr-dev libmpc-dev libssl-dev bison flex

BASEDIR=`pwd`

# TOOLCHAIN

cd $BASEDIR
mkdir -p toolchains/aarch64
cd toolchains/aarch64

export TOOLCHAIN=`pwd`

cd "$TOOLCHAIN"
wget https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.bz2
tar -xf binutils-2.32.tar.bz2
mkdir binutils-2.32-build
cd binutils-2.32-build
../binutils-2.32/configure --prefix="$TOOLCHAIN" --target=aarch64-linux-gnu --disable-nls
make -j4
make install

cd "$TOOLCHAIN"
wget https://ftp.gnu.org/gnu/gcc/gcc-9.1.0/gcc-9.1.0.tar.gz
tar -xf gcc-9.1.0.tar.gz
mkdir gcc-9.1.0-build
cd gcc-9.1.0-build
../gcc-9.1.0/configure --prefix="$TOOLCHAIN" --target=aarch64-linux-gnu --with-newlib --without-headers --disable-nls --disable-shared --disable-threads --disable-libssp --disable-decimal-float --disable-libquadmath --disable-libvtv --disable-libgomp --disable-libatomic --enable-languages=c
make all-gcc -j4
make install-gcc

