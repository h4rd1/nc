ARG BASE_IMAGE=ubuntu:22.04

FROM ${BASE_IMAGE} as documentserver
LABEL maintainer Ascensio System SIA <support@onlyoffice.com>

ARG PG_VERSION=14
ARG OOU_VERSION_MAJOR=8.0.1
ARG OOU_BUILD=1

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive PG_VERSION=${PG_VERSION}

ARG ONLYOFFICE_VALUE=onlyoffice

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && \
    apt-get -y update && \
    apt-get -yq install wget apt-transport-https gnupg locales lsb-release && \
    locale-gen en_US.UTF-8 && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get -yq install \
        adduser \
        apt-utils \
        bomstrip \
        certbot \
        cron \
        curl \
        htop \
        libasound2 \
        libboost-regex-dev \
        libcairo2 \
        libcurl3-gnutls \
        libcurl4 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libstdc++6 \
        libxml2 \
        libxss1 \
        libxtst6 \
        mysql-client \
        nano \
        net-tools \
        netcat-openbsd \
        nginx-extras \
        postgresql \
        postgresql-client \
        pwgen \
        rabbitmq-server \
        redis-server \
        software-properties-common \
        sudo \
        vim\
        supervisor \
        ttf-mscorefonts-installer \
        xvfb \
        zlib1g && \
    if [  $(ls -l /usr/share/fonts/truetype/msttcorefonts | wc -l) -ne 61 ]; \
        then echo 'msttcorefonts failed to download'; exit 1; fi  && \
    echo "SERVER_ADDITIONAL_ERL_ARGS=\"+S 1:1\"" | tee -a /etc/rabbitmq/rabbitmq-env.conf && \
    sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf && \
    sed 's|\(application\/zip.*\)|\1\n    application\/wasm wasm;|' -i /etc/nginx/mime.types && \
    pg_conftool $PG_VERSION main set listen_addresses 'localhost' && \
    service postgresql restart && \
    sudo -u postgres psql -c "CREATE USER $ONLYOFFICE_VALUE WITH password '$ONLYOFFICE_VALUE';" && \
    sudo -u postgres psql -c "CREATE DATABASE $ONLYOFFICE_VALUE OWNER $ONLYOFFICE_VALUE;" && \
    service postgresql stop && \
    service redis-server stop && \
    service rabbitmq-server stop && \
    service supervisor stop && \
    service nginx stop && \
    rm -rf /var/lib/apt/lists/*

COPY config/supervisor/supervisor /etc/init.d/
COPY config/supervisor/ds/*.conf /etc/supervisor/conf.d/
COPY run-document-server.sh /app/ds/run-document-server.sh

EXPOSE 80 443

ARG COMPANY_NAME=onlyoffice
ARG PRODUCT_NAME=documentserver
ARG PRODUCT_EDITION=
ARG PACKAGE_VERSION=
ARG TARGETARCH
ARG PACKAGE_BASEURL="http://download.onlyoffice.com/install/documentserver/linux"

ENV COMPANY_NAME=$COMPANY_NAME \
    PRODUCT_NAME=$PRODUCT_NAME \
    PRODUCT_EDITION=$PRODUCT_EDITION \
    DS_DOCKER_INSTALLATION=true

## PACKAGE_FILE="${COMPANY_NAME}-${PRODUCT_NAME}${PRODUCT_EDITION}${PACKAGE_VERSION:+_$PACKAGE_VERSION}_${TARGETARCH:-$(dpkg --print-architecture)}.deb" && \
##    wget -q -P /tmp "$PACKAGE_BASEURL/$PACKAGE_FILE" && \
##    rm -f /tmp/onlyoffice-documentserver*.deb && \
RUN    wget -q -P /tmp "https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/download/onlyoffice-unlimited-build-debian-11%2F8.1.3.3/onlyoffice-documentserver_8.1.3-3-btactic_amd64.deb" && \
    apt-get -y update && \
    service postgresql start && \
    apt-get -yq install /tmp/onlyoffice-documentserver_8.1.3-3-btactic_amd64.deb && \
    service postgresql stop && \
    chmod 755 /etc/init.d/supervisor && \
    sed "s/COMPANY_NAME/${COMPANY_NAME}/g" -i /etc/supervisor/conf.d/*.conf && \
    service supervisor stop && \
    chmod 755 /app/ds/*.sh && \
    rm -f /tmp/onlyoffice-documentserver_8.1.3-3-btactic_amd64.deb && \
    rm -rf /var/log/$COMPANY_NAME && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/log/$COMPANY_NAME /var/lib/$COMPANY_NAME /var/www/$COMPANY_NAME/Data /var/lib/postgresql /var/lib/rabbitmq /var/lib/redis /usr/share/fonts/truetype/custom

RUN sed -i -e 's/104857600/10485760000/g' /etc/onlyoffice/documentserver-example/production-linux.json
RUN sed -i '9iclient_max_body_size 1000M;' /etc/onlyoffice/documentserver-example/nginx/includes/ds-example.conf
RUN sed -i '16iclient_max_body_size 1000M;' /etc/nginx/nginx.conf 
RUN sed -i -e 's/104857600/10485760000/g' /etc/onlyoffice/documentserver/default.json
RUN sed -i -e 's/50MB/5000MB/g' /etc/onlyoffice/documentserver/default.json
RUN sed -i -e 's/300MB/3000MB/g' /etc/onlyoffice/documentserver/default.json

ENTRYPOINT ["/app/ds/run-document-server.sh"]





