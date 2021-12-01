#!/bin/bash

set -xe

IS_FORCE=0
if [ "$1" = "--force" ]; then
	IS_FORCE=1
fi

push() {
	TAG="$1"; shift
	IMAGE_NAME=xaionaro2/edk2-builder:"$TAG"

	docker rmi "$IMAGE_NAME" 2>/dev/null || true
	EDK2_VERSION="$TAG" DOCKERFILE_PATH=Dockerfile IMAGE_NAME="$IMAGE_NAME" hooks/build
	docker push "$IMAGE_NAME"
	docker rmi "$IMAGE_NAME"
}

push "latest"

for TAG in $(git ls-remote --tags https://github.com/tianocore/edk2 | awk '{print $2}' | sed -e 's%refs/tags/%%g' | grep -v '{}'); do
	IMAGE_NAME=xaionaro2/edk2-builder:"$TAG"
	if [ "$IS_FORCE" -eq 0 ]; then
		if DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "$IMAGE_NAME"; then
			continue
		fi
	fi
	push "$TAG"
done

