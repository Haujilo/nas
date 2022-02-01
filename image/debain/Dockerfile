FROM debian:11-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Shanghai

ENV LANG C.UTF-8

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo "$LANG UTF-8" > /etc/locale.gen && \
  apt-get -y update &&  apt-get -y upgrade && \
  apt-get -y install tzdata locales snapd net-tools apt-transport-https ca-certificates procps curl && \
  update-ca-certificates --fresh && \
  rm -rf /var/lib/apt/lists/*