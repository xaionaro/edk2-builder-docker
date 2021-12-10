all:
	make clean
	# Uncomment the commented lines below to rebuild the Docker image
	#cp ../../build-edk2.sh . && cp ../../clone-edk2.sh . && cp ../../entry.sh .
	#EDK2_VERSION=RefindPlusUDKJVT DOCKERFILE_PATH=../../Dockerfile.RefindPlus IMAGE_NAME=xaionaro2/edk2-builder:RefindPlusUDKJVT ../../hooks/build
	# Comment out the docker pull line in Build.sh file
	mkdir build
	cd build && . ../build.sh
	cd build && . ../build1.sh

clean:
	rm -rf build
