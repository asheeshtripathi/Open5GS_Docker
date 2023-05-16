#Deriving the latest base image
FROM    ubuntu:jammy

#Labels as key value pair
LABEL Maintainer="asheeshtripathi"

# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         security_updates_as_of 2023-05-15

# Install Open5GS dependencies
RUN         apt-get -y install -q \
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
RUN           apt-get update
RUN           apt-get -y install -q mongodb-org
RUN           systemctl start mongod
RUN           systemctl enable mongod

#Setting up TUN device (not persistent after rebooting)
RUN           ip tuntap add name ogstun mode tun
RUN           ip addr add 10.45.0.1/16 dev ogstun
RUN           ip addr add 2001:db8:cafe::1/48 dev ogstun
RUN           ip link set ogstun up

#Building Open5GS
RUN          git clone https://github.com/open5gs/open5gs
WORKDIR /open5gs
RUN          meson build --prefix=`pwd`/install
RUN          ninja -C build   
RUN          ./build/tests/registration/registration                
WORKDIR /open5gs/build
RUN          meson test -v
RUN          ninja install
WORKDIR /open5gs

#Building the WebUI of Open5GS
RUN          apt-get -y install -q curl
RUN          curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN          apt-get -y install -q nodejs
WORKDIR /open5gs/webui
RUN          npm ci
RUN          npm run dev

# Adding a route for the UE to have WAN connectivity
RUN          sysctl -w net.ipv4.ip_forward=1
RUN          sysctl -w net.ipv6.conf.all.forwarding=1
RUN          iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
RUN          ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE
RUN          ufw disable
RUN          iptables -I INPUT -i ogstun -j ACCEPT
RUN          iptables -I INPUT -s 10.45.0.0/16 -j DROP
RUN          ip6tables -I INPUT -s 2001:db8:cafe::/48 -j DROP
