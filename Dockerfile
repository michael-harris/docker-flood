FROM lsiobase/alpine:3.8

# set env
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV FLOOD_SECRET=4F1988366B4D8EFAF5206FBDEBDAB7D72BEE3AEC3D5F3E050FEFEE4367A178E5
ENV CONTEXT_PATH=/
ENV PUID=0
ENV PGID=0

ARG MEDIAINF_VER="18.05"
ARG CURL_VER="7.61.0"
    
RUN NB_CORES=${BUILD_CORES-`getconf _NPROCESSORS_CONF`} && \
  apk update && \
  apk upgrade && \
  apk add --no-cache \
    bash-completion \
    ca-certificates \
    ffmpeg \
    curl \
    gzip \
    dtach \
    tar \
    unrar \
    unzip \
    sox \
    wget \
    zlib \
    zlib-dev \
    git \
    libressl \
    binutils \
    findutils \
    mediainfo \
    libmediainfo \
    python \
    zip \
    python2 \
    nodejs \
    nodejs-npm && \
# install build packages
  apk add --no-cache --virtual=build-dependencies \
    autoconf \
    automake \
    cppunit-dev \
    perl-dev \
    file \
    g++ \
    gcc \
    libtool \
    make \
    ncurses-dev \
    build-base \
    libtool \
    subversion \
    cppunit-dev \
    linux-headers \
    curl-dev \
    libressl-dev && \
# compile curl to fix ssl for rtorrent
  cd /tmp && \
  mkdir curl && \
  cd curl && \
  wget -qO- https://curl.haxx.se/download/curl-${CURL_VER}.tar.gz | tar xz --strip 1 && \
  ./configure --with-ssl && make -j ${NB_CORES} && make install && \
  ldconfig /usr/bin && ldconfig /usr/lib && \
# install flood
  mkdir /usr/flood && \
  cd /usr/flood && \
  git clone https://github.com/jfurrow/flood . && \
  cp config.template.js config.js && \
  npm install -g node-gyp && \
  npm install && \
  npm cache clean --force && \
  npm run build && \
  rm config.js && \
# cleanup
  apk del --purge build-dependencies && \
  apk del -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main cppunit-dev && \
  rm -rf /tmp/*

# add default config file
COPY includes/ /

# ports and volumes
EXPOSE 3000 
VOLUME /config /downloads /socket
