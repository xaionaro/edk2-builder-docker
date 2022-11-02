#!/bin/bash -xe

mkdir -m 1777 out

# We clone the edk2 source code again, just to be able to
# do custom changes to OVMF, but this is not necessary.
git clone https://github.com/tianocore/edk2 edk2 -b edk2-stable202208
docker pull xaionaro2/edk2-builder:edk2-stable202208

docker run --rm \
    -e CFLAGS=-Wno-error \
    -e DSC_PATH=OvmfPkg/OvmfPkgX64.dsc \
    -e BUILD_TARGET=RELEASE \
    -v "$PWD/edk2/OvmfPkg:/home/edk2/src/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:edk2-stable202208
