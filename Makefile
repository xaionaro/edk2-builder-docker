
all:
	docker build -t xaionaro2/edk2-builder .

clean:
	docker rmi xaionaro2/edk2-builder
