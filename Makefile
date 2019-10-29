.PHONY: all
all: docker

.PHONY: clean
clean:
	rm -rf output/*

.PHONY: docker
docker: 
	docker build -t video-tools:stable .

.PHONY: push
push: docker
	docker tag video-tools:stable offbytwo/video-tools:stable
	docker push offbytwo/video-tools:stable
