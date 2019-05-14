FROM ubuntu:bionic
LABEL maintainer="Mark Lopez <m@silvenga.com>"

# Base from https://github.com/evarga/docker-images

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN set -xe \
    && apt-get -q update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    locales \
    && locale-gen en_US.UTF-8 \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y \
    openssh-server \
    sudo \
    && apt-get -q autoremove \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin \
    && sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
    && mkdir -p /var/run/sshd \
    && useradd -m -d /home/jenkins -s /bin/sh jenkins \
    && echo "jenkins:jenkins" | chpasswd

RUN set -xe \
    && apt-get -q update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y software-properties-common \
    && add-apt-repository -y ppa:openjdk-r/ppa \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y openjdk-8-jre-headless \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Docker
RUN set -xe \
    && apt-get -q update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get -q update \
    docker-ce \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin \
    && usermod -aG docker jenkins

# Git
RUN apt-get -q update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y \
    git \
    wget \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Nodejs
RUN set -xe \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_8.x | -E bash - \
    && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y \
    build-essential \
    nodejs \
    yarn \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# pi-gen
RUN apt-get -q update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -y install \
    git \
    vim \
    parted \
    quilt \
    coreutils \
    qemu-user-static \
    debootstrap \
    zerofree \
    zip dosfstools \
    bsdtar \
    libcap2-bin \
    rsync \
    grep \
    udev \
    xz-utils \
    curl \
    xxd \
    file \
    kmod \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
