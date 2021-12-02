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

find /home/edk2 -wholename '*/BaseTools/Source/C/*[mM]akefile' -exec sed -e 's/-Werror//g' -i {} +
find /home/edk2 -wholename '*/BaseTools/Source/C' -exec make -C {} \;

if [ "$DSC_PATH" != '' ]; then
    IFS=':' read -ra PKG_PATHS <<< "$PACKAGES_PATH"
    for PKG_PATH in "${PKG_PATHS[@]}"; do
        if [ -f "${PKG_PATH}/${DSC_PATH}" ]; then
            DSC_PATH="${PKG_PATH}/${DSC_PATH}"
            break
        fi
    done
fi
if [ "$DSC_PATH" = '' ]; then
  DSC_PATH="$(readlink -f /home/edk2/src/*.dsc)"
fi
if [ "$DSC_PATH" = '' ]; then
  DSC_PATH="$(readlink -f /home/edk2/src/*/*.dsc)"
fi

if [ "$CC_FLAGS" != '' ]; then
    CC_FLAGS_SETTING="${BUILD_TARGET}_${TOOLCHAIN}_${TARGET_ARCH}_CC_FLAGS"
    append_cc_flags_to_tools_def() {
        TOOLS_DEF_PATH="$1"; shift
        cp -v "$TOOLS_DEF_PATH"-orig "$TOOLS_DEF_PATH" 2>/dev/null ||
          cp -v "$TOOLS_DEF_PATH" "$TOOLS_DEF_PATH"-orig 2>/dev/null
        if grep -E "^${TOOLCHAIN}_${TARGET_ARCH}_CC_FLAGS[ \t=]" "$TOOLS_DEF_PATH"-orig; then
            echo "${CC_FLAGS_SETTING} = DEF(${TOOLCHAIN}_${TARGET_ARCH}_CC_FLAGS) ${CC_FLAGS}" >> "$TOOLS_DEF_PATH"
        else
            if grep -E "^${CC_FLAGS_SETTING}[ \t=]" "$TOOLS_DEF_PATH"-orig; then
                sed -re 's/^('"${CC_FLAGS_SETTING}"'[ \t=][^\r]*)/\1 '"${CC_FLAGS}/" -i "$TOOLS_DEF_PATH"
            else
                echo "${CC_FLAGS_SETTING} = ${CC_FLAGS}" >> "$TOOLS_DEF_PATH"
            fi
        fi
    }
    find /home/edk2 -name "tools_def.txt" | while read -r TOOLS_DEF_PATH; do
        append_cc_flags_to_tools_def "$TOOLS_DEF_PATH"
    done
    append_cc_flags_to_tools_def "/home/edk2/edk2/Conf/tools_def.txt"

    for DSC_PATH_ITEM in ${DSC_PATH[0]}; do
        cp -v "${DSC_PATH_ITEM}"-orig "${DSC_PATH_ITEM}" 2>/dev/null ||
            cp -v "${DSC_PATH_ITEM}" "${DSC_PATH_ITEM}"-orig
        echo -e "\n[BuildOptions.common]\n${CC_FLAGS_SETTING} = ${CC_FLAGS}\n" >> "${DSC_PATH_ITEM}"
    done
fi

echo "PATH:<$PATH>"
echo "DSC_PATH:<$DSC_PATH>"
echo "PACKAGES_PATH:<$PACKAGES_PATH>"
gcc --version

for DSC_PATH_ITEM in ${DSC_PATH[0]}; do
  build -v -p "$DSC_PATH_ITEM" -a "$TARGET_ARCH" -b "$BUILD_TARGET" -t "$TOOLCHAIN" $OPTIONS || exit
done
