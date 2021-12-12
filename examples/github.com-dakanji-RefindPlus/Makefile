all:
	make clean
	cp ../../build-edk2.sh . && cp ../../clone-edk2.sh . && cp ../../entry.sh .
	EDK2_VERSION=RefindPlusUDK DOCKERFILE_PATH=../../Dockerfile.RefindPlus IMAGE_NAME=xaionaro2/edk2-builder:RefindPlusUDK ../../hooks/build
	mkdir build
	cd build && . ../build.sh
	cd build && . ../build1.sh

clean:
	rm -rf build
