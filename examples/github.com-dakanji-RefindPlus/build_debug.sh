#!/bin/bash -xe

mkdir -m 1777 out

git clone --recursive https://github.com/dakanji/RefindPlus RefindPlusPkg
chmod -R 1777 RefindPlusPkg
# Comment out the docker pull line to use the rebuild Docker image in Makefile 
# Remove the comments in the Makefile as well to start the rebuild process.

docker pull xaionaro2/edk2-builder:RefindPlusUDK

# hacky fix for duplication error of lodepng_malloc and lodepng_free
sed -e 's/void[*] lodepng_malloc/void* _dup_lodepng_malloc/' \
    -e 's/void lodepng_free/void _dup_lodepng_free/' \
    -i-orig RefindPlusPkg/libeg/lodepng_xtra.c

# building DEBUG
exec docker run --rm \
    -e CFLAGS=-Wno-error \
    -e TOOLCHAIN=CLANG38 \
    -e BUILD_TARGET=DEBUG \
    -e DSC_PATH=RefindPlusPkg/RefindPlusPkg-DBG.dsc \
    -v "$PWD/RefindPlusPkg/:/home/edk2/edk2/RefindPlusPkg/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:RefindPlusUDK
    
