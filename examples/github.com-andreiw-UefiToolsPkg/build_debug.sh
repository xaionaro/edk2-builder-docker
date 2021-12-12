#!/bin/bash -xe

mkdir -m 1777 out

git clone --recursive https://github.com/andreiw/UefiToolsPkg

# removing "SetCon" from the list if components, because the tool is not buildable
sed -e 's%  UefiToolsPkg/Applications/SetCon/SetCon.inf%#  UefiToolsPkg/Applications/SetCon/SetCon.inf%' \
    -i-orig UefiToolsPkg/UefiToolsPkg.dsc

exec docker run --rm \
  -e CFLAGS=-Wno-error \
  -e DSC_PATH=UefiToolsPkg/UefiToolsPkg.dsc \
  -e BUILD_TARGET=DEBUG \
  -v "$PWD/:/home/edk2/src" -v "$PWD/out:/home/edk2/Build" \
  xaionaro2/edk2-builder:vUDK2018
