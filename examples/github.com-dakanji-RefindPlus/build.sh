#!/bin/bash -xe

mkdir -pm 1777 out ||
	mkdir -p out

git clone --recursive https://github.com/dakanji/RefindPlus RefindPlusPkg
docker pull xaionaro2/edk2-builder:RefindPlusUDK

 sed -e 's/void[*] lodepng_refit_malloc/void* _dup_lodepng_refit_malloc/' \
     -e 's/void lodepng_refit_free/void _dup_lodepng_refit_free/' \
     -i-orig RefindPlusPkg/libeg/lodepng_xtra.c

docker run --rm \
    -e CFLAGS=-Wno-error \
    -e TOOLCHAIN=CLANG38 \
    -e BUILD_TARGET=RELEASE \
    -e DSC_PATH=RefindPlusPkg/RefindPlusPkg.dsc \
    -v "$PWD/RefindPlusPkg/:/home/edk2/edk2/RefindPlusPkg/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:RefindPlusUDK
