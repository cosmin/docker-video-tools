FROM nvidia/cuda:9.2-base-ubuntu18.04
LABEL maintainer "Cosmin Stejerean <cosmin@offbytwo.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get upgrade -y && \
    apt-get -y install --no-install-recommends \
    cuda-npp-9-2 cuda-driver-dev-9-2 \
    libva2 libva-drm2 \
    libass9 \
    libnuma1 \
    libfreetype6 \
    libvorbisenc2 libvorbis0a \
    && apt-get -y clean && rm -r /var/lib/apt/lists/*

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ADD output/packager /opt/packager
ADD output/ffmpeg /opt/ffmpeg

ENV PATH /opt/ffmpeg/bin:/opt/packager/bin:$PATH
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
RUN echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/zz_cuda_stubs.conf
RUN ln -s /opt/ffmpeg/share/model /usr/local/share/
RUN ldconfig
