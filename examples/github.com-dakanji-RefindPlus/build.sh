#!/bin/bash -xe

mkdir -m 1777 out

git clone --recursive https://github.com/dakanji/RefindPlus RefindPlusPkg
docker pull xaionaro2/edk2-builder:RefindPlusUDK

# hacky fix for duplication error of lodepng_malloc and lodepng_free
sed -e 's/void[*] lodepng_refit_malloc/void* _dup_lodepng_refit_malloc/' \
    -e 's/void lodepng_refit_free/void _dup_lodepng_refit_free/' \
    -i-orig RefindPlusPkg/libeg/lodepng_xtra.c


cat > RefindPlusPkg/build.sh <<EOF
/home/edk2/entry.sh
EOF
chmod +x RefindPlusPkg/build.sh

docker run --rm \
    -e CFLAGS=-Wno-error \
    -e TOOLCHAIN=CLANG38 \
    -e BUILD_TARGET=RELEASE \
    -e DSC_PATH=RefindPlusPkg/RefindPlusPkg.dsc \
    -v "$PWD/RefindPlusPkg/:/home/edk2/edk2/RefindPlusPkg/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:RefindPlusUDK /bin/bash /home/edk2/edk2/RefindPlusPkg/build.sh
