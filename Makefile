CI_BUILD_NUMBER ?= 0
IMAGE_NAME_BASE=utm

all: oci-images

oci-images:
	docker buildx build --build-arg TOKEN_TYPE=none -t $(IMAGE_NAME_BASE):none -t $(IMAGE_NAME_BASE):none-$(CI_BUILD_NUMBER) .
	docker buildx build --build-arg TOKEN_TYPE=rutoken -t $(IMAGE_NAME_BASE):rutoken -t $(IMAGE_NAME_BASE):rutoken-$(CI_BUILD_NUMBER) .
	docker buildx build --build-arg TOKEN_TYPE=rutoken -t $(IMAGE_NAME_BASE):mskey -t $(IMAGE_NAME_BASE):mskey-$(CI_BUILD_NUMBER) .
	docker buildx build --build-arg TOKEN_TYPE=rutoken -t $(IMAGE_NAME_BASE):jacarta -t $(IMAGE_NAME_BASE):jacarta-$(CI_BUILD_NUMBER) .

up-rutoken:
	docker run --rm -it -e DEBUG=true -e TZ=Europe/Moscow -p 8080:8080 --device=/dev/bus/usb/002/002 -v ${PWD}/logs:/var/log utm:rutoken