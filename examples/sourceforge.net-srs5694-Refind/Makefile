all:
	make clean
	EDK2_VERSION=vUDK2018 DOCKERFILE_PATH=../../Dockerfile.Refind IMAGE_NAME=xaionaro2/edk2-builder:vUDK2018 ../../hooks/build
	mkdir build
	cd build && . ../build.sh
	cd build && . ../build1.sh

clean:
	rm -rf build
