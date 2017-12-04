# Notice:
# When updating this file, please also update virtualization/Docker/Dockerfile.dev
# This way, the development image and the production image are kept in sync.

FROM python:3.6
LABEL maintainer="Paulus Schoutsen <Paulus@PaulusSchoutsen.nl>"

# Uncomment any of the following lines to disable the installation.
#ENV INSTALL_TELLSTICK no
#ENV INSTALL_OPENALPR no
#ENV INSTALL_FFMPEG no
#ENV INSTALL_LIBCEC no
#ENV INSTALL_PHANTOMJS no
#ENV INSTALL_SSOCR no

##################################################
# (Added to upstream Dockerfile.)
##################################################

# Install dependencies for node, as well as some helpful utilities for debugging
# a live container.
RUN apt-get install -y curl wget nano vim

# Install node.
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -; \
    apt-get install -y nodejs

##################################################
# (End of added stuff.)
##################################################

VOLUME /config

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy build scripts
COPY virtualization/Docker/ virtualization/Docker/
RUN virtualization/Docker/setup_docker_prereqs

# Install hass component dependencies
COPY requirements_all.txt requirements_all.txt
# Uninstall enum34 because some dependencies install it but breaks Python 3.4+.
# See PR #8103 for more info.
RUN pip3 install --no-cache-dir -r requirements_all.txt && \
    pip3 install --no-cache-dir mysqlclient psycopg2 uvloop cchardet cython

# Copy source
COPY . .

##################################################
# (Added to upstream Dockerfile.)
##################################################

# Upstream uses the command below, but I've added a wrapper that does additional
# runtime configuration and starts some additional services.
# CMD [ "python", "-m", "homeassistant", "--config", "/config" ]
CMD ["./run.sh"]

##################################################
# (End of added stuff.)
##################################################
