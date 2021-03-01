#!/bin/bash
set -x

cd /home/edk2 || exit 2

if [ "$CFLAGS" != '' ]; then
    BUILD_CFLAGS+=($CFLAGS)
    CC_FLAGS+=($CFLAGS)
fi

if [ "$EDK2VERSION" != 'master' ]; then
    make -C edk2/BaseTools clean
    git -C edk2 checkout "$EDK2VERSION" || exit 1
    if [ "$BUILD_CFLAGS" != '' ]; then
        cp -v /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile-orig /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile 2>/dev/null ||
          cp -v /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile-orig
        echo "BUILD_CFLAGS += $BUILD_CFLAGS" >> /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile
    fi
    make -C edk2/BaseTools -j 8 && make -C /home/edk2/edk2/BaseTools/Source/C || (
      # fixing a bug in "vUDK2017"
      sed -e 's/#include "VfrTokens.h"/#include <VfrTokens.h>/g' -i edk2/BaseTools/Source/C/VfrCompile/VfrSyntax.cpp &&
      make -C edk2/BaseTools -j 8
      make -C /home/edk2/edk2/BaseTools/Source/C
    )
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

if [ "$CC_FLAGS" != '' ]; then
    cp -v /home/edk2/edk2/Conf/tools_def.txt-orig /home/edk2/edk2/Conf/tools_def.txt 2>/dev/null ||
      cp -v /home/edk2/edk2/Conf/tools_def.txt /home/edk2/edk2/Conf/tools_def.txt-orig
    echo "${BUILD_TARGET}_${TOOLCHAIN}_${TARGET_ARCH}_CC_FLAGS = DEF(${TOOLCHAIN}_${TARGET_ARCH}_CC_FLAGS) ${CC_FLAGS}" >> /home/edk2/edk2/Conf/tools_def.txt
fi

echo "$PATH"
echo "$PACKAGES_PATH"
gcc --version

exec build -v -p $DSC_PATH -a "$TARGET_ARCH" -b "$BUILD_TARGET" -t "$TOOLCHAIN" $OPTIONS