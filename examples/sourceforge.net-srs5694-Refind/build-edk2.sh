#!/bin/bash
set -x

cd "/home/edk2"

if [ "$BUILD_CFLAGS" = '' ]; then
  # Variety of EDK2 versions just do not build with a recent GCC version due to '-Werror'.
  BUILD_CFLAGS='-Wno-error'
fi
if [ "$BUILD_CXXFLAGS" = '' ]; then
  # Variety of EDK2 versions just do not build with a recent GCC version due to '-Werror'.
  BUILD_CXXFLAGS='-Wno-error'
fi

cp -v /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile-orig /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile 2>/dev/null ||
  cp -v /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile-orig
(
  echo ""
  echo "BUILD_CFLAGS += $BUILD_CFLAGS"
  echo "BUILD_CXXFLAGS += $BUILD_CXXFLAGS"
) >> /home/edk2/edk2/BaseTools/Source/C/Makefiles/header.makefile

# skip tests
sed -e 's/all: test/all:\n\t@echo noop/g' -i edk2/BaseTools/Tests/GNUmakefile

# fixing a bug in "vUDK2017"
sed -e 's/#include "VfrTokens.h"/#include <VfrTokens.h>/g' -i edk2/BaseTools/Source/C/VfrCompile/VfrSyntax.cpp 2>/dev/null || true

# fixing a bug in 2021
sed -e 's/-Werror//g' -i edk2/src/RefindPlusUDK/BaseTools/Source/C/Makefiles/header.makefile 2>/dev/null || true

# Speed-up the process with `-j`. But it seems EDK2 sometimes fails if we parallelize the building,
# so we retry without `-j`
make -C edk2/BaseTools -j $(nproc) || make -C edk2/BaseTools
make -C edk2/BaseTools/Source/C -j $(nproc) || make -C edk2/BaseTools/Source/C