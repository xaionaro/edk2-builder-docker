EDK_VERSION=latest

all:
	DOCKER_TAG=$(EDK_VERSION) DOCKERFILE_PATH=Dockerfile IMAGE_NAME=xaionaro2/edk2-builder:$(EDK_VERSION) hooks/build

clean:
	docker rmi xaionaro2/edk2-builder
