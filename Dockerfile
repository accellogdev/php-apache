# FROM php:7.0-apache AS webservice
# FROM php:7.2-apache AS webservice
# FROM php:7.4-apache AS webservice
# FROM php:8.0-apache AS webservice
FROM php:8.2-apache AS webservice

LABEL maintainer="valter@accellog.com"

# correcao NO_PUBKEY 0E98404D386FA1D9
# https://stackoverflow.com/questions/77256696/docker-with-php-8-2-raised-error-the-public-key-is-not-available
RUN mv -i /etc/apt/trusted.gpg.d/debian-archive-*.asc  /root/     ### move /etc/apt/trusted.gpg.d/debian-archive-*.asc to /root/ or to any persistent place you will remember.
RUN ln -s /usr/share/keyrings/debian-archive-* /etc/apt/trusted.gpg.d/
RUN apt update

# ferramentas básicas para o funcionamento
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get install -y vim \
    && apt-get install -y net-tools \
    && apt-get install -y wget

# instalando PostgreSQL PDO
RUN apt-get update \
    && apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# instalando o componente zip do php
# RUN apt-get update \
#     && apt-get install -y zlib1g-dev \
#     && docker-php-ext-install zip
# Install zip
RUN apt-get update \
	&& apt-get install -y libzip-dev \
	&& docker-php-ext-install zip

# módulo necessário para redirecionar para HTTPS
RUN a2enmod rewrite \
    && a2enmod socache_shmcb \
    && a2enmod ssl




# --------------------------------
# instalando JDK
# --------------------------------
# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# ENV JAVA_HOME /usr/local/openjdk-8
# ENV PATH $JAVA_HOME/bin:$PATH

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:8u382-b05-jdk $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# backwards compatibility shim
RUN { echo '#/bin/sh'; echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ]
# --------------------------------

# instalando composer
# https://hub.docker.com/_/composer/
# RUN apt-get update \
#     && apt-get install -y git subversion mercurial unzip

# RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini"

# ENV COMPOSER_ALLOW_SUPERUSER 1
# ENV COMPOSER_HOME /tmp
# ENV COMPOSER_VERSION 1.8.4

# RUN curl --silent --fail --location --retry 3 --output /tmp/installer.php --url https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer \
#  && php -r " \
#     \$signature = '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5'; \
#     \$hash = hash('sha384', file_get_contents('/tmp/installer.php')); \
#     if (!hash_equals(\$signature, \$hash)) { \
#         unlink('/tmp/installer.php'); \
#         echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
#         exit(1); \
#     }" \
#  && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
#  && composer --ansi --version --no-interaction \
# && rm -f /tmp/installer.php

# instalando composer
# https://hub.docker.com/_/composer/
COPY --from=composer:2.6.5 /usr/bin/composer /usr/bin/composer

# baixando e configurando scripts certbot-auto
# RUN  cd /usr/bin \
#     && wget https://dl.eff.org/certbot-auto \
#     && chmod a+x ./certbot-auto \
#     && ./certbot-auto --os-packages-only -n

# componentes para o envio de emails e emissão de recibos
# https://github.com/exozet/docker-php-fpm
RUN apt-get update -y && apt-get install -y \
    sendmail \
    libpng-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libxpm-dev \
    libwebp-dev  # php >=7.0 (use libvpx for php <7.0)

# RUN docker-php-ext-install mbstring \
#     && docker-php-ext-install gettext
# mbstring já existe no PHP 7.4 / 8.0
RUN docker-php-ext-install gettext

# RUN docker-php-ext-configure gd \
#     --with-freetype-dir=/usr/include/ \
#     --with-jpeg-dir=/usr/include/ \
#     --with-xpm-dir=/usr/include \
#     --with-webp-dir=/usr/include/ # php >=7.0 (use libvpx for php <7.0)
# PHP 7.0/8.0
RUN docker-php-ext-configure gd

RUN docker-php-ext-install gd

RUN chmod 777 -R /var/www

# RUN apt-get update -y && apt-get install -y sendmail libpng-dev \
#     && docker-php-ext-install mbstring \
#     && docker-php-ext-install gd \
#     && docker-php-ext-install gettext

RUN apt-get update && \
    apt-get install -y \
        libc-client-dev libkrb5-dev && \
    rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

# Instalando ferramentas para segurança DDoS e SlowLoris
# RUN apt-get update && \
# 	apt-get -y install libapache2-mod-evasive libapache2-mod-qos && \
# 	a2enmod evasive

RUN docker-php-ext-configure bcmath && \
    docker-php-ext-install bcmath

VOLUME /var/www/html
WORKDIR /var/www/html
EXPOSE 80 80
EXPOSE 443 443
