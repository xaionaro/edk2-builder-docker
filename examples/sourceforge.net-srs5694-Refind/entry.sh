#!/bin/bash
set -x

cd /home/edk2 || exit 2

if [ "$CFLAGS" != '' ]; then
    BUILD_CFLAGS+=($CFLAGS)
    BUILD_CXXFLAGS+=($CFLAGS)
    CC_FLAGS+=($CFLAGS)
fi
export BUILD_CFLAGS
export BUILD_CXXFLAGS

if [ "$EDK2VCOMMIT" != '' ]; then
    make -C edk2/BaseTools clean
    git -C edk2 checkout "$EDK2COMMIT" || exit 1
    /home/edk2/build-edk2.sh
fi

if [ "$ADDPATH" != '' ]; then
    export PATH="$ADDPATH:$PATH"
fi

DEFAULT_PACKAGES_PATH="/home/edk2:/home/edk2/src:/home/edk2/edk2:/home/edk2/libc:/home/edk2/platforms"
if [ "$PACKAGES_PATH" != '' ]; then
    export PACKAGES_PATH="$PACKAGES_PATH:$DEFAULT_PACKAGES_PATH"
else
    export PACKAGES_PATH="$DEFAULT_PACKAGES_PATH"
fi

cd /home/edk2/edk2 || exit 2
. edksetup.sh

if [ "$DSC_PATH" = '' ]; then
  DSC_PATH="$(readlink -f /home/edk2/src/*.dsc)"
fi
if [ "$DSC_PATH" = '' ]; then
  DSC_PATH="$(readlink -f /home/edk2/src/*/*.dsc)"
fi

if [ "$CC_FLAGS" != '' ]; then
    CC_FLAGS_SETTING="${BUILD_TARGET}_${TOOLCHAIN}_${TARGET_ARCH}_CC_FLAGS"
    if [ -f /home/edk2/edk2/Conf/tools_def.txt ]; then
        cp -v /home/edk2/edk2/Conf/tools_def.txt-orig /home/edk2/edk2/Conf/tools_def.txt 2>/dev/null ||
          cp -v /home/edk2/edk2/Conf/tools_def.txt /home/edk2/edk2/Conf/tools_def.txt-orig
        echo "${CC_FLAGS_SETTING} = DEF(${TOOLCHAIN}_${TARGET_ARCH}_CC_FLAGS) ${CC_FLAGS}" >> /home/edk2/edk2/Conf/tools_def.txt
    else
        for DSC_PATH_ITEM in ${DSC_PATH[0]}; do
            cp -v "${DSC_PATH_ITEM}"-orig "${DSC_PATH_ITEM}" 2>/dev/null ||
                cp -v "${DSC_PATH_ITEM}" "${DSC_PATH_ITEM}"-orig
            echo -e "\n[BuildOptions.common]\n${CC_FLAGS_SETTING} = ${CC_FLAGS}\n" >> "${DSC_PATH_ITEM}"
        done
    fi
fi

echo "$PATH"
echo "$PACKAGES_PATH"
gcc --version

for DSC_PATH_ITEM in ${DSC_PATH[0]}; do
  build -v -p "$DSC_PATH_ITEM" -a "$TARGET_ARCH" -b "$BUILD_TARGET" -t "$TOOLCHAIN" $OPTIONS || exit
done