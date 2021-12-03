#!/bin/bash

if [ "$REGISTRY_LOGIN" = "" ]; then
	echo "error: REGISTRY_LOGIN is not set. Exit." >&2
	exit 1
fi

if [ "$REGISTRY_KEY" = "" ]; then
	echo "error: REGISTRY_KEY is not set. Exit." >&2
	exit 2
fi

if [ "$REGISTRY_IMAGE_NAME" = "" ]; then
	echo "error: REGISTRY_IMAGE_NAME is not set. Exit." >&2
	exit 3
fi

set -xe

IS_FORCE=0
if [ "$1" = "--force" ]; then
	IS_FORCE=1
	shift
fi


if [ "$REGISTRY_ADDR" != '' ]; then
	docker login "$REGISTRY_ADDR" -u "$REGISTRY_LOGIN" --password-stdin <<< "$REGISTRY_KEY"
else
	docker login -u "$REGISTRY_LOGIN" --password-stdin <<< "$REGISTRY_KEY"
fi

image_name() {
	TAG="$1"; shift

	if [ "$REGISTRY_ADDR" != '' ]; then
		echo -n "$REGISTRY_ADDR"/"$REGISTRY_IMAGE_NAME":"$TAG"
	else
		echo -n "$REGISTRY_IMAGE_NAME":"$TAG"
	fi
}

push() {
	TAG="$1"; shift
	IMAGE_NAME="$(image_name "$TAG")"

	docker rmi "$IMAGE_NAME" 2>/dev/null || true
	EDK2_VERSION="$TAG" DOCKERFILE_PATH=Dockerfile IMAGE_NAME="$IMAGE_NAME" hooks/build
	docker push "$IMAGE_NAME"
	docker rmi "$IMAGE_NAME"
}

if [ "$@" != "" ]; then
	TAGS=($@)
else
	TAGS=(latest $(git ls-remote --tags https://github.com/tianocore/edk2 | awk '{print $2}' | sed -e 's%refs/tags/%%g' | grep -v '{}') RefindPlusUDK AcidantheraAUDK)
fi
echo "TAGS:<${TAGS[@]}>"

for TAG in "${TAGS[@]}"; do
	IMAGE_NAME="$(image_name "$TAG")"
	if [ "$TAG" != "latest" -a "$IS_FORCE" -eq 0 ]; then
		if DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "$IMAGE_NAME"; then
			continue
		fi
	fi
	push "$TAG"
done

