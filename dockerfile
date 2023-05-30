#Deriving the latest base image
FROM    ubuntu:jammy

#Labels as key value pair
LABEL Maintainer="asheeshtripathi"

# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         security_updates_as_of 2023-05-15

# Install Open5GS dependencies
RUN     apt-get update  &&      apt-get -y install -q \
                autoconf \
                automake \
                build-essential \
                flex \
                bison \
                git \
                libsctp-dev \
                libgnutls28-dev \
                libgcrypt-dev \
                libssl-dev \
                libidn11-dev \
                libmongoc-dev \
                libbson-dev \
                libyaml-dev \
                libnghttp2-dev \
                libmicrohttpd-dev \
                libcurl4-gnutls-dev \
                libnghttp2-dev \
                libtins-dev \
                libtalloc-dev \
                meson \
                cpufrequtils \
                ethtool \
                g++ \
                libncurses5 \
                libncurses5-dev \
                inetutils-tools \
                libboost-all-dev \
                libusb-1.0-0 \
                libusb-1.0-0-dev \
                libudev-dev \
                python3-pip \
                python3-wheel \
                python3-mako \
                ninja-build \
                doxygen \
                python3-docutils \
                python3-scipy \
                python3-setuptools \
                cmake \
                python3-requests \
                python3-numpy \
                dpdk \
                python3-ruamel.yaml \
                libdpdk-dev
#Getting MongoDB
RUN     apt-get update  &&      apt-get -y install -q curl
RUN     apt-get update  &&      apt-get -y install -q gnupg


#Building Open5GS
RUN     git clone https://github.com/open5gs/open5gs
WORKDIR /open5gs
RUN     meson build --prefix=`pwd`/install
RUN     ninja -C build
WORKDIR /open5gs/build
RUN     ninja install
WORKDIR /open5gs


RUN     apt-get -y install -q net-tools
RUN     apt-get -y install -q vim

