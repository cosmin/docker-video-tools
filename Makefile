.PHONY: all
all: docker

output:
	mkdir -p output

.PHONY: clean
clean:
	rm -rf output/*

output/vmaf: output
	docker run -v "$(shell pwd)/output:/output" -it offbytwo/vmaf cp -r /opt/vmaf /output/

output/packager: output
	docker run -v "$(shell pwd)/output:/output" -it offbytwo/shaka-packager cp -r /opt/packager /output/

output/ffmpeg: output
	docker run -v "$(shell pwd)/output:/output" -it offbytwo/ffmpeg cp -r /opt/ffmpeg /output/

.PHONY: docker
docker: output/ffmpeg output/vmaf output/packager
	docker build -t video-tools .

.PHONY: push
push: docker
	docker tag video-tools offbytwo/video-tools
	docker push offbytwo/video-tools
