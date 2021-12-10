all:
	make clean
	# Uncomment the lines 5 below to rebuild the Docker image. Comment out 5 to use
	# the existing image. Comment out the docker pull line in Build.sh file.
	EDK2_VERSION=vUDK2018 DOCKERFILE_PATH=../../Dockerfile.Refind IMAGE_NAME=xaionaro2/edk2-builder:vUDK2018 ../../hooks/build
	mkdir build
	cd build && . ../build.sh
	cd build && . ../build1.sh

clean:
	rm -rf build
