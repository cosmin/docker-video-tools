.PHONY: all
all: docker

output:
	mkdir -p output

.PHONY: clean
clean:
	rm -rf output/*

output/packager: output
	docker run -v "$(shell pwd)/output:/output" -it offbytwo/shaka-packager cp -r /opt/packager /output/

output/ffmpeg: output
	docker run -v "$(shell pwd)/output:/output" -it offbytwo/ffmpeg cp -r /opt/ffmpeg /output/

.PHONY: docker
docker: output/ffmpeg output/packager
	docker build -t video-tools .

.PHONY: push
push: docker
	docker tag video-tools offbytwo/video-tools
	docker push offbytwo/video-tools
