FROM alpine:3.18 as build

ENV LANG C.UTF-8
RUN set -xe \
    && apk update \
    && apk add --no-cache --virtual .build-dependencies \
                git \
                abuild \
                binutils \
                build-base \
                automake \
                autoconf \
                argp-standalone \
                linux-headers \
                libev-dev \
                libusb-dev \
                cmake \
                dev86 \ 
                gcc
RUN set -xe \
     && apk add --no-cache \
                udev \
                bash \
                libusb \
                libev \
                libgcc \
                libstdc++ \
                libtool

ARG KNXD_VERSION
RUN git clone --branch "$KNXD_VERSION" --depth 1 https://github.com/knxd/knxd.git \
     && cd knxd \
     && chmod 777 ./bootstrap.sh \
     && ./bootstrap.sh \
     && ./configure --disable-systemd \
     --enable-busmonitor \
     --enable-tpuart \
     --enable-usb \
     --enable-eibnetipserver \
     --enable-eibnetip \
     --enable-eibnetserver \
     --enable-eibnetiptunnel \
     --enable-groupcache \
     && mkdir -p src/include/sys && ln -s /usr/lib/bcc/include/sys/cdefs.h src/include/sys \
     && make \
     && mkdir /install \
     && make DESTDIR=/install install
#     && make install \
#     && make clean \
#     && cd .. \
#     && rm -rf knxd
#RUN apk del --purge .build-dependencies

FROM alpine:3.18

# get needed runtime libs
RUN set -xe \
     && apk add --no-cache \
                udev \
                bash \
                libusb \
                libev \
                libgcc \
                libstdc++ \
                libtool

# copy knxd files and libs
COPY --from=build /install/ /

# copy knxd configuration
COPY knxd.ini /etc/

ENTRYPOINT ["knxd", "/etc/knxd.ini"]
