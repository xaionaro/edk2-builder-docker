
all:
	docker build -t github.com/xaionaro/edk2-builder-docker .

clean:
	docker rmi github.com/xaionaro/edk2-builder-docker
