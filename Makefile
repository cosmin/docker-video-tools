.PHONY: all
all: docker

.PHONY: clean
clean:
	rm -rf output/*

.PHONY: docker
docker: 
	docker build -t video-tools:latest .

.PHONY: push
push: docker
	docker tag video-tools:latest offbytwo/video-tools:latest
	docker push offbytwo/video-tools:latest
