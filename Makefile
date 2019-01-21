.PHONY: all
all: docker

.PHONY: docker
docker:
	docker build -t video-tools:experimental .

.PHONY: push
push: docker
	docker tag video-tools:experimental offbytwo/video-tools:experimental
	docker push offbytwo/video-tools:experimental
