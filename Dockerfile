FROM nvidia/cuda:9.2-devel-ubuntu18.04
LABEL maintainer "Cosmin Stejerean <cosmin@offbytwo.com>"

# Install dependent packages
RUN apt-get -y update && apt-get install -y curl wget nano git-core build-essential pkg-config \
    autoconf automake cmake libass-dev libssl-dev libfreetype6-dev libtool pkg-config texinfo \
    wget zlib1g-dev mercurial libnuma-dev nasm \
    libtheora-dev libvorbis-dev librtmp-dev \
    libssh-dev openssl ocl-icd-opencl-dev opencl-headers

RUN mkdir -p /opt/sources

RUN echo 'installing NVCODEC headers...'
RUN git clone https://github.com/FFmpeg/nv-codec-headers /opt/sources/nv-codec-headers
WORKDIR /opt/sources/nv-codec-headers
RUN make -j8
RUN make install
RUN rm -rf /opt/sources/nv-codec-headers

RUN echo 'building x264...'
WORKDIR /opt/sources
RUN git clone --depth 1 https://git.videolan.org/git/x264
WORKDIR /opt/sources/x264
RUN ./configure --enable-static --enable-pic
RUN make -j8
RUN make install
RUN rm -rf /opt/sources/x264

RUN echo 'building x265...'
WORKDIR /opt/sources
RUN hg clone https://bitbucket.org/multicoreware/x265
WORKDIR /opt/sources/x265/build/linux
RUN cmake -G "Unix Makefiles" ../../source
RUN make -j8
RUN make install
RUN rm -rf /opt/sources/x265

RUN echo 'installing fdk_aac...'
WORKDIR /opt/sources
RUN git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
WORKDIR /opt/sources/fdk-aac
RUN autoreconf -fiv
RUN ./configure --disable-shared
RUN make -j8
RUN make install

RUN echo 'building opus...'
WORKDIR /opt/sources
RUN curl -O -L https://archive.mozilla.org/pub/opus/opus-1.2.1.tar.gz
RUN tar xzvf opus-1.2.1.tar.gz
WORKDIR /opt/sources/opus-1.2.1
RUN ./configure
RUN make -j8
RUN make install

RUN echo 'building libvpx...'
WORKDIR /opt/sources
RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
WORKDIR /opt/sources/libvpx
RUN ./configure --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=nasm
RUN make -j8
RUN make install
RUN rm -rf /opt/sources/libvpx

RUN echo 'building libaom...'
WORKDIR /opt/sources
RUN git clone --depth 1 https://aomedia.googlesource.com/aom
RUN mkdir /opt/sources/aom_build
WORKDIR /opt/sources/aom_build
RUN cmake /opt/sources/aom
RUN make -j8
RUN make install
RUN rm -rf /opt/sources/aom*

RUN echo 'building shaka packager...'
WORKDIR /opt
RUN git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH /opt/depot_tools:$PATH
WORKDIR /opt/sources
RUN mkdir shaka_packager
WORKDIR /opt/shaka_packager
RUN gclient config https://www.github.com/google/shaka-packager.git --name=src
RUN gclient sync --no-history
RUN cd src && ninja -C out/Release
RUN mkdir -p /opt/packager/bin
RUN mkdir -p /opt/packager/lib
RUN cp src/out/Release/packager /opt/packager/bin/
RUN cp src/out/Release/mpd_generator /opt/packager/bin/
RUN cp src/out/Release/libpackager.a /opt/packager/lib/
RUN ln -s /opt/packager/bin/packager /usr/local/bin/packager
RUN rm -rf /opt/depot_tools
RUN rm -rf /opt/sources/shaka_packager

RUN echo 'building ffmpeg...'
WORKDIR /opt/sources
RUN git clone --depth 1 https://github.com/FFmpeg/FFmpeg
WORKDIR /opt/sources/FFmpeg
RUN ./configure \
    --enable-version3 \
    --enable-nonfree \
    --enable-nvenc \
    --enable-cuda \
    --enable-cuvid \
    --enable-libnpp \
    --extra-cflags="-I/usr/local/cuda/include" \
    --extra-cflags="-I/usr/local/include" \
    --extra-ldflags="-L/usr/local/cuda/lib64" \
    --extra-ldflags="-L/usr/local/lib" \
    --enable-libfdk-aac \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libaom \
    --enable-opencl \
    --enable-libopus \
    --enable-libssh \
    --enable-openssl \
    --enable-gpl \
    --pkg-config-flags=--static \
    --extra-libs="-lpthread -lm"
RUN make -j8
RUN make install -j8
RUN rm -rf /opt/sources/FFmpeg

RUN apt-get -y clean
RUN rm -r /var/lib/apt/lists/*