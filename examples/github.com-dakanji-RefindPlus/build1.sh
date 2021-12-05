#!/bin/bash -xe

# building RELEASE
exec docker run --rm \
    -e CFLAGS=-Wno-error \
    -e TOOLCHAIN=CLANG38 \
    -e BUILD_TARGET=RELEASE \
    -e DSC_PATH=RefindPlusPkg/RefindPlusPkg-REL.dsc \
    -v "$PWD/RefindPlusPkg/:/home/edk2/edk2/RefindPlusPkg/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:RefindPlusUDK
    
