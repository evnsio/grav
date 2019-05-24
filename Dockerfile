FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

# Desired version of grav
ARG GRAV_VERSION=1.6.7
ARG TINI_VERSION=v0.18.0

# Install dependencies
RUN apt-get update && \
    apt-get install -y sudo nginx wget vim unzip php php-curl php-gd php-pclzip php-zip php-mbstring gnupg2

RUN apt-get install php-fpm -y && \
    apt-get purge apache2 -y

ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

# Set user to www-data
RUN mkdir -p /var/www && chown www-data:www-data /var/www
USER www-data

# Install grav
WORKDIR /var/www
RUN wget https://github.com/getgrav/grav/releases/download/$GRAV_VERSION/grav-admin-v$GRAV_VERSION.zip && \
    unzip grav-admin-v$GRAV_VERSION.zip && \
    rm grav-admin-v$GRAV_VERSION.zip && \
    cd grav-admin && \
    bin/gpm install -f -y admin

# Return to root user
USER root

# Install Acmetool Let's Encrypt client
RUN echo 'deb http://ppa.launchpad.net/hlandau/rhea/ubuntu xenial main' > /etc/apt/sources.list.d/rhea.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9862409EF124EC763B84972FF5AC9651EDB58DFA \
    && apt-get update \
    && apt-get install acmetool -y

# Configure nginx with grav
WORKDIR grav-admin
RUN cd webserver-configs && \
    sed -i 's/root \/home\/USER\/www\/html/root \/var\/www\/grav-admin/g' nginx.conf && \
    cp nginx.conf /etc/nginx/conf.d/default.conf

# Set the file permissions
# RUN usermod -aG www-data nginx
RUN mkdir -p /run/php
# Run startup script
ADD resources /
ENTRYPOINT [ "/usr/local/bin/tini", "--", "/usr/local/bin/startup.sh" ]
