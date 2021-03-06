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
docker run --rm \
  -e CFLAGS=-Wno-error \
  -e DSC_PATH=UefiToolsPkg/UefiToolsPkg.dsc \
  -v "$PWD/:/home/edk2/src" -v "/tmp/UefiToolsPkg-build:/home/edk2/Build" \
  xaionaro2/edk2-builder:vUDK2018
```
That's it :)

The result will be in `/tmp/UefiToolsPkg-build`.

Explanation:
* `vUDK2018` is [a version of EDK2](https://github.com/tianocore/edk2/tags).
* Directory `/home/edk2/Build` is defined in `UefiToolsPkg/UefiToolsPkg.dsc` as `Build`, since the working directory is `/home/edk2`
* Directory `/home/edk2/src` is hardcoded in the `Dockerfile` as the directory with the source code of what do we want to compile.
