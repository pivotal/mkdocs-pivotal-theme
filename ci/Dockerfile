FROM ubuntu:bionic

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update --fix-missing
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:brightbox/ruby-ng
RUN add-apt-repository ppa:longsleep/golang-backports
RUN apt-get update --fix-missing
RUN apt-get install -y \
  python3 \
  python3-cffi \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  ruby-full \
  ruby2.6 \
  ruby2.6-dev \
  golang-go \
  git \
  wget
RUN wget -O - https://github.com/BurntSushi/ripgrep/releases/download/12.0.1/ripgrep-12.0.1-x86_64-unknown-linux-musl.tar.gz | tar zxf - --strip-component=1
RUN mv rg /usr/local/bin/
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN go get -u github.com/raviqqe/muffet
