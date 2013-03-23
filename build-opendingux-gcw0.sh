#!/bin/sh

## -- OPENDINGUX USER SETTINGS

## OPENDINGUX - This should point to the root of your tool-chain {i.e. folder above the BIN dir}

OPENDINGUX=/opt/gcw0-toolchain/usr
SYSROOT=/opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/usr

## HOST and TARGET - These should be the canonical tool names of your tool.
## For the sake of this script HOST and TARGET should be the same.
## Defaults would be 'mipsel-linux'.

HOST=mipsel-gcw0-linux-uclibc
TARGET=mipsel-gcw0-linux-uclibc
BUILD=`uname -m`
PKG_CONFIG_PATH=/opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/usr/lib/pkgconfig 

## -- END OPENDINGUX USER SETTINGS

export OPENDINGUX
export HOST
export TARGET
export PKG_CONFIG_PATH

PREFIX=$OPENDINGUX
export PREFIX

PATH=$PATH:$OPENDINGUX/bin
export PATH

#ln -s `whereis -b pkg-config | sed 's/pkg-config\: //g'` /opt/gcw0-toolchain/usr/bin/pkg-config

# Do not edit below here
CC="${OPENDINGUX}/bin/${HOST}-gcc"
CXX="${OPENDINGUX}/bin/${HOST}-g++"
AR="${OPENDINGUX}/bin/${HOST}-ar"
STRIP="${OPENDINGUX}/bin/${HOST}-strip"
RANLIB="${OPENDINGUX}/bin/${HOST}-ranlib"
LD="${OPENDINGUX}/bin/${HOST}-ld"

CFLAGS="-DNO_ZLIB -D_REENTRANT -DTARGET_OPENDINGUX_GCW0 -O2 -funroll-loops -ffast-math -fomit-frame-pointer -fno-strength-reduce -finline-functions -G0 -march=mips32 -mtune=mips32r2"
LDFLAGS="-L${SYSROOT}/lib -D_REENTRANT -ldl -lcrypto"
#PKG_CONFIG="${OPENDINGUX}/bin/pkg-config"

export CC
export CXX
export AR
export STRIP
export RANLIB
export LD

export CFLAGS
export LDFLAGS
export PKG_CONFIG

echo Current settings.
echo
echo Install root/Working dir	= $OPENDINGUX
echo Tool locations 		    = $OPENDINGUX/bin
echo Host/Target		        = $HOST / $TARGET
echo

echo CC         = $CC
echo CXX        = $CXX
echo AR         = $AR
echo STRIP      = $STRIP
echo RANLIB     = $RANLIB
echo LD         = $LD

echo CFLAGS     = $CFLAGS
echo LDFLAGS    = $LDFLAGS
echo PKG_CONFIG = $PKG_CONFIG

echo "### Building 3rd party software ###"

cd 3rdparty/des-4.04b
case $1 in
    release)
        make clean && make
        ;;

    *)
        make
        ;;
esac
if [ $? -ne 0 ]; then
    echo "*** ABORT ***"
    exit 1
fi
cd -

echo "### Building BennuGD Core ###"

cd core
case $1 in
    release)
        ./configure --prefix=${PREFIX} --target=${TARGET} --host=${HOST} --build=${BUILD} --enable-shared PKG_CONFIG_LIBDIR=${PKG_CONFIG_PATH} && make clean && make
        ;;

    *)
        make
        ;;
esac
if [ $? -ne 0 ]; then
    echo "*** ABORT ***"
    exit 1
fi
cd -

echo "### Building BennuGD Modules ###"

cd modules
case $1 in
    release)
        ./configure --prefix=${PREFIX} --target=${TARGET} --host=${HOST} --build=${BUILD} --enable-shared PKG_CONFIG_LIBDIR=${PKG_CONFIG_PATH} && make clean && make
        ;;

    *)
        make
        ;;
esac
if [ $? -ne 0 ]; then
    echo "*** ABORT ***"
    exit 1
fi
cd -

echo "### Building BennuGD Tools ###"

cd tools/moddesc
case $1 in
    release)
        ./configure --prefix=${PREFIX} --target=${TARGET} --host=${HOST} --build=${BUILD} --enable-shared PKG_CONFIG_LIBDIR=${PKG_CONFIG_PATH} && make clean && make
        ;;

    *)
        make
        ;;
esac
if [ $? -ne 0 ]; then
    echo "*** ABORT ***"
    exit 1
fi
cd -

echo "### Copying files to bin folder ###"

mkdir -p bin/$TARGET 2>/dev/null
cp 3rdparty/des-4.04b/libdes.so bin/$TARGET
cp core/bgdi/src/.libs/bgdi bin/$TARGET
cp core/bgdc/src/bgdc bin/$TARGET
cp core/bgdrtm/src/.libs/libbgdrtm.so bin/$TARGET
cp $(find modules -name '*.so') bin/$TARGET
cp tools/moddesc/moddesc bin/$TARGET

echo "### Build done! ###"

exit 0
