FROM ubuntu:24.04
MAINTAINER OneZoom <mail@onezoom.org>

ARG VCS_REF
ARG UBUNTU_VERSION
ARG DEBUG=false

LABEL description="Docker baseimage" os_version="Ubuntu ${UBUNTU_VERSION}" \
      org.label-schema.vcs-ref=${VCS_REF} org.label-schema.vcs-url="https://github.com/onezoom/docker-base"

ENV HOME=/root
ENV UBUNTU_VERSION=${UBUNTU_VERSION}

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

WORKDIR /root

CMD ["/sbin/my_init"]
