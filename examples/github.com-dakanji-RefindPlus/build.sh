#!/bin/bash -xe

mkdir -m 1777 out

git clone --recursive https://github.com/dakanji/RefindPlus RefindPlusPkg
docker pull xaionaro2/edk2-builder:RefindPlusUDK

# hacky fix for duplication error of lodepng_malloc and lodepng_free
sed -e 's/void[*] lodepng_malloc/void* _dup_lodepng_malloc/' \
    -e 's/void lodepng_free/void _dup_lodepng_free/' \
    -i RefindPlusPkg/libeg/lodepng_xtra.c

# building
exec docker run --rm \
    -e CFLAGS=-Wno-error \
    -e TOOLCHAIN=CLANG38 \
    -e DSC_PATH=RefindPlusPkg/RefindPlusPkg-DBG.dsc \
    -v "$PWD/RefindPlusPkg/:/home/edk2/edk2/RefindPlusPkg/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:RefindPlusUDK
