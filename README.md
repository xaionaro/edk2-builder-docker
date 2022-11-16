![Build examples](https://github.com/xaionaro/edk2-builder-docker/actions/workflows/github-actions-test.yml/badge.svg)
![DockerHub](https://github.com/xaionaro/edk2-builder-docker/actions/workflows/github-actions-push.yml/badge.svg)

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law,
  <a rel="dct:publisher"
     href="https://github.com/xaionaro/">
    <span property="dct:title">Dmitrii Okunev</span></a>
  has waived all copyright and related or neighboring rights to
  "<span property="dct:title">A docker image to build EDK2-based projects</span>.
This work is published from:
<span property="vcard:Country" datatype="dct:ISO3166"
      content="IE" about="https://github.com/xaionaro/edk2-builder-docker">
  Ireland</span>".
</p>

# Goal

The purpose of this project is to prepare a comprehensive build environment which will just build EDK2 based projects without tons of pain.

# Quick start

Take any EDK2-based project you need to compile, for example "[github.com/andreiw/UefiToolsPkg](https://github.com/andreiw/UefiToolsPkg)":
```sh
cd "`mktemp -d`"
mkdir -m 1777 /tmp/UefiToolsPkg-build

git clone --recursive https://github.com/andreiw/UefiToolsPkg
docker pull xaionaro2/edk2-builder:vUDK2018

# removing "SetCon" from the list if components, because the tool is not buildable
sed -e 's%  UefiToolsPkg/Applications/SetCon/SetCon.inf%#  UefiToolsPkg/Applications/SetCon/SetCon.inf%' \
    -i-orig UefiToolsPkg/UefiToolsPkg.dsc

docker run --rm \
  -e CFLAGS=-Wno-error \
  -e DSC_PATH=UefiToolsPkg/UefiToolsPkg.dsc \
  -e BUILD_TARGET=DEBUG \
  -v "$PWD/:/home/edk2/src" -v "/tmp/UefiToolsPkg-build:/home/edk2/Build" \
  xaionaro2/edk2-builder:vUDK2018
```
That's it :)

The result will be in `/tmp/UefiToolsPkg-build`.

Explanation:
* `vUDK2018` is [a version of EDK2](https://github.com/tianocore/edk2/tags).
* Directory `/home/edk2/Build` is defined in `UefiToolsPkg/UefiToolsPkg.dsc` as `Build`, since the working directory is `/home/edk2`
* Directory `/home/edk2/src` is hardcoded in the `Dockerfile` as the directory with the source code of what do we want to compile.

### Another example

```sh
cd "`mktemp -d`"
mkdir -m 1777 /tmp/RefindPlusPkg-build

git clone --recursive https://github.com/dakanji/RefindPlus RefindPlusPkg
docker pull xaionaro2/edk2-builder:RefindPlusUDK

# hacky fix for duplication error of lodepng_malloc and lodepng_free
sed -e 's/void[*] lodepng_malloc/void* _dup_lodepng_malloc/' \
    -e 's/void lodepng_free/void _dup_lodepng_free/' \
	-e 's/void[*] lodepng_refit_malloc/void* _dup_lodepng_refit_malloc/' \
    -e 's/void lodepng_refit_free/void _dup_lodepng_refit_free/' \
    -i-orig RefindPlusPkg/libeg/lodepng_xtra.c

# hacky fix to remove "STATIC_ASSERT undefined" error
cat > RefindPlusPkg/build.sh <<EOF
sed -e 's%STATIC_ASSERT%//STATIC_ASSERT%' -i edk2/OpenCorePkg/Library/OcUnicodeCollationEngLib/OcUnicodeCollationEngCommon.c
sed -e 's%"UnicodeLanguages%//"UnicodeLanguages%' -i edk2/OpenCorePkg/Library/OcUnicodeCollationEngLib/OcUnicodeCollationEngCommon.c
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
```

### OVMF

```sh
cd "`mktemp -d`"

# We clone the edk2 source code again, just to be able to
# do custom changes to OVMF, but this is not necessary.
git clone https://github.com/tianocore/edk2 edk2 -b edk2-stable202208

docker run --rm \
    -e CFLAGS=-Wno-error \
    -e DSC_PATH=OvmfPkg/OvmfPkgX64.dsc \
    -e BUILD_TARGET=RELEASE \
    -v "$PWD/edk2/OvmfPkg:/home/edk2/src/" \
    -v "$PWD/out:/home/edk2/Build" \
    xaionaro2/edk2-builder:edk2-stable202208
```

# Rebuild

For example if one needs to build the latest EDK2 then they may use:
```sh
EDK2_VERSION=latest DOCKERFILE_PATH=Dockerfile IMAGE_NAME=xaionaro2/edk2-builder:latest hooks/build
```

Or if [`edk2-stable202111`](https://github.com/tianocore/edk2/tags) then:
```
EDK2_VERSION=edk2-stable202111 DOCKERFILE_PATH=Dockerfile IMAGE_NAME=xaionaro2/edk2-builder:stable202111 hooks/build
```

# Add a custom EDK2 repository

Fork the repository, add the repository to file [`clone-edk2.sh`](https://github.com/xaionaro/edk2-builder-docker/blob/main/clone-edk2.sh) with a new special tag,
and then run:
```
EDK2_VERSION=<THE SPECIAL TAG HERE> DOCKERFILE_PATH=Dockerfile IMAGE_NAME=<SOME IMAGE NAME>:<SOME TAG> hooks/build
```
It will build a docker image `<SOME IMAGE NAME>:<SOME TAG>` using the custom EDK2 repository.

It would also be nice if after that there will be a Pull Request to push this changes back to here :)
