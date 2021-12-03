#!/bin/bash -xe

mkdir -pm 1777 out

[[ -d RefindPkg ]] || git clone --recursive https://git.code.sf.net/p/refind/code RefindPkg
docker pull xaionaro2/edk2-builder:vUDK2018

# building DEBUG
exec docker run --rm \
    -e CFLAGS=-Wno-error \
    -e TOOLCHAIN=GCC5 \
    -e BUILD_TARGET=DEBUG \
    -e DSC_PATH=RefindPkg/RefindPkg.dsc \
    -v "$PWD/RefindPkg/:/home/edk2/edk2/RefindPkg/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:vUDK2018

# building RELEASE
exec docker run --rm \
    -e CFLAGS=-Wno-error \
    -e TOOLCHAIN=GCC5 \
    -e BUILD_TARGET=RELEASE \
    -e DSC_PATH=RefindPkg/RefindPkg.dsc \
    -v "$PWD/RefindPkg/:/home/edk2/edk2/RefindPkg/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:vUDK2018
