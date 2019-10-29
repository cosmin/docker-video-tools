FROM offbytwo/ffmpeg:experimental as ffmpeg
FROM offbytwo/shaka-packager:experimental as packager

FROM ubuntu:bionic
LABEL maintainer "Cosmin Stejerean <cosmin@offbytwo.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get upgrade -y && \
    apt-get -y install --no-install-recommends \
    libnuma1 \
    libssl1.1 \
    gpac \
    libfreetype6 \
    && apt-get -y clean && rm -r /var/lib/apt/lists/*

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY --from=packager /opt/packager /opt/packager
COPY --from=ffmpeg /opt/ffmpeg /opt/ffmpeg

ENV PATH /opt/ffmpeg/bin:/opt/packager/bin:$PATH
RUN ln -s /opt/ffmpeg/share/model /usr/local/share/
RUN ldconfig
