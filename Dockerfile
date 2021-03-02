FROM ubuntu:20.04
MAINTAINER Dmitrii Okunev <xaionaro@dx.center>

RUN \
	DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
	    bison \
		build-essential \
		ccache \
		curl \
		flex \
		gcc-7 libgcc-7-dev \
		gcc-9 libgcc-9-dev gcc-9-aarch64-linux-gnu gcc-9-arm-linux-gnueabihf \
		gcc-10 libgcc-10-dev gcc-10-aarch64-linux-gnu gcc-10-arm-linux-gnueabihf \
		gcc cross-gcc-dev gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf \
		git \
		iasl \
		nasm \
		sudo \
		python \
		python-dev \
		python3 \
		python3-distutils \
		python3-pip \
		qemu \
		uuid-dev \
		vim \
		wget \
		zip \
	&& DEBIAN_FRONTEND=noninteractive apt-get clean

RUN curl https://bootstrap.pypa.io/2.7/get-pip.py --output /tmp/get-pip.py && python /tmp/get-pip.py
RUN pip3 install -q uefi_firmware && pip install -q uefi_firmware

RUN useradd -m edk2 && \
	adduser edk2 sudo && \
	sed -e 's/ALL$/NOPASSWD: ALL/' -i /etc/sudoers

RUN mkdir /home/edk2/.ccache && \
	chown edk2:edk2 /home/edk2/.ccache

VOLUME /home/edk2/.ccache

USER edk2
WORKDIR /home/edk2

ENV PYTHON_COMMAND python3

RUN git clone "https://github.com/tianocore/edk2" edk2
RUN git clone "https://github.com/tianocore/edk2-libc" libc
RUN git clone "https://github.com/tianocore/edk2-platforms" platforms

ARG DOCKER_TAG=${DOCKER_TAG}
RUN echo "DOCKER_TAG:<$DOCKER_TAG>" && if [ "$DOCKER_TAG" != '' -a "$DOCKER_TAG" != 'latest' ]; then git -C edk2 checkout "$DOCKER_TAG"; fi
RUN git -C edk2 submodule update --init
ADD build-edk2.sh /home/edk2/build-edk2.sh
RUN /home/edk2/build-edk2.sh

RUN mkdir -p /home/edk2/src /home/edk2/gcc/7 /home/edk2/gcc/9 /home/edk2/gcc/10 && \
    ln -s /usr/bin/gcc-7 /home/edk2/gcc/7/gcc && \
    ln -s /usr/bin/gcc-9 /home/edk2/gcc/9/gcc && \
    ln -s /usr/bin/gcc-10 /home/edk2/gcc/10/gcc

ENV WORKSPACE "/home/edk2"
ENV TOOLCHAIN "GCC5"
ENV TARGET_ARCH "X64"
ENV BUILD_TARGET "DEBUG"
ADD build-edk2.sh /home/edk2/build-edk2.sh
ADD entry.sh /home/edk2/entry.sh
CMD /bin/bash /home/edk2/entry.sh
