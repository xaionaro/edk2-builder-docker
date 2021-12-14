all:
	make clean
	cp ../../build-edk2.sh . && cp ../../clone-edk2.sh . && cp ../../entry.sh .
	EDK2_VERSION=RefindPlusUDKJVT DOCKERFILE_PATH=../../Dockerfile IMAGE_NAME=xaionaro2/edk2-builder:RefindPlusUDKJVT ../../hooks/build
	mkdir build
	cd build && . ../build_debug.sh
	cd build && . ../build_release.sh

clean:
	rm -rf build
