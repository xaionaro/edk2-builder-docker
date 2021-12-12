all:
	make clean
	cp ../../build-edk2.sh . && cp ../../clone-edk2.sh . && cp ../../entry.sh .
	EDK2_VERSION=vUDK2018 DOCKERFILE_PATH=../../Dockerfile IMAGE_NAME=xaionaro2/edk2-builder:vUDK2018 ../../hooks/build
	mkdir build
	cd build && . ../build_debug.sh
	cd build && . ../build_release.sh

clean:
	rm -rf build
