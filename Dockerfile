FROM debian:jessie
MAINTAINER github/tmlbl

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update
RUN apt-get install -y wget make build-essential git

## Install LDC

WORKDIR /opt/

RUN wget https://github.com/ldc-developers/ldc/releases/download/v0.15.1/ldc2-0.15.1-linux-x86_64.tar.gz
RUN tar xvf ldc2-0.15.1-linux-x86_64.tar.gz
RUN mv ldc2-0.15.1-linux-x86_64 ldc
RUN ln -s /opt/ldc/bin/ldc2 /usr/bin/ldc2

RUN ldc2
