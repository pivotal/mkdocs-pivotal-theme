FROM ubuntu

RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update --fix-missing
RUN apt-get install -y \
  python3 \
  python3-cffi \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  ruby2.6 \
  ruby2.6-dev
RUN wget -O - https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz | tar zxf - --strip-component=1
RUN mv rg /usr/local/bin/