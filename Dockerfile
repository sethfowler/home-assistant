# This is a Dockerfile for home-assistant which includes node and other useful
# tools by default. You can install more packages without rebuilding the image
# by editing /config/install.sh in the container.
FROM debian:jessie-slim

# This Dockerfile is based on both the original home-assistant Dockerfile and
# the homebridge Dockerfile.
MAINTAINER Seth Fowler <seth@blackhail.net>

# Debugging helpers
##################################################
RUN alias ll='ls -alG'

# Set environment variables
##################################################
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Install tools
##################################################
RUN apt-get update; \
    apt-get install -y apt-utils apt-transport-https; \
    apt-get upgrade -y; \
    apt-get install -y locales curl wget; \
    apt-get install -y libnss-mdns avahi-discover libavahi-compat-libdnssd-dev libkrb5-dev; \
    apt-get install -y nano vim \
    apt-get install -y python3

# Install node
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -; \
    apt-get install -y nodejs

VOLUME /config

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN pip3 install --no-cache-dir colorlog cython

# For the nmap tracker, bluetooth tracker, Z-Wave, tellstick
RUN echo "deb http://download.telldus.com/debian/ stable main" >> /etc/apt/sources.list.d/telldus.list && \
    wget -qO - http://download.telldus.se/debian/telldus-public.key | apt-key add - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nmap net-tools cython3 libudev-dev sudo libglib2.0-dev bluetooth libbluetooth-dev \
            libtelldus-core2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY script/build_python_openzwave script/build_python_openzwave
RUN script/build_python_openzwave && \
  mkdir -p /usr/local/share/python-openzwave && \
  ln -sf /usr/src/app/build/python-openzwave/openzwave/config /usr/local/share/python-openzwave/config

COPY requirements_all.txt requirements_all.txt
RUN pip3 install --no-cache-dir -r requirements_all.txt && \
    pip3 install mysqlclient psycopg2 uvloop

# Copy source
COPY . .

CMD ["./run.sh"]
