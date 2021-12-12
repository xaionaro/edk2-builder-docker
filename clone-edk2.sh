#!/bin/bash -xe

echo "EDK2_VERSION:<$EDK2_VERSION>"
case "$EDK2_VERSION" in
	latest)
		git clone --depth=1 "https://github.com/tianocore/edk2" edk2
		;;
		RefindPlusUDK)
		git clone --depth=1 "https://github.com/dakanji/RefindPlusUDK" edk2
		;;
	RefindPlusUDKJVT)
		git clone --depth=1 "https://github.com/joevt/RefindPlusUDK" edk2
		;;		
	AcidantheraAUDK)
		git clone --depth=1 "https://github.com/acidanthera/audk" edk2
		;;
	*)
		git clone --depth=1 -b "$EDK2_VERSION" "https://github.com/tianocore/edk2" edk2 || \
 			git clone "https://github.com/tianocore/edk2" edk2
		;;
esac
git -C edk2 submodule update --init --recommend-shallow
