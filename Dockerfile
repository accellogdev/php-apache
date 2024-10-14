FROM php:7.2-apache AS webservice

LABEL maintainer="gustavo@accellog.com"

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
RUN apt-get update \
    && apt-get install -y zlib1g-dev \
    && docker-php-ext-install zip

# módulo necessário para redirecionar para HTTPS
RUN a2enmod rewrite \
    && a2enmod socache_shmcb \
    && a2enmod ssl

# instalando Redis
RUN pecl install redis \
	&& docker-php-ext-enable redis

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

# -------------------------------- fim instalando JDK

# instalando composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN apt-get update -y && apt-get install -y \
  sendmail \
  libpng-dev \
  libfreetype6-dev \
  libjpeg-dev \
  libxpm-dev \
  libwebp-dev  # php >=7.0 (use libvpx for php <7.0)

RUN docker-php-ext-install mbstring \
    && docker-php-ext-install gettext

RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-xpm-dir=/usr/include \
    --with-webp-dir=/usr/include/ # php >=7.0 (use libvpx for php <7.0)

RUN docker-php-ext-install gd \
    && docker-php-ext-install gettext
	
RUN chmod 777 -R /var/www

RUN apt-get update && \
    apt-get install -y \
        libc-client-dev libkrb5-dev && \
    rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

## definindo php.ini
COPY php.ini-production /usr/local/etc/php/php.ini

WORKDIR /var/www/html
EXPOSE 80 80
EXPOSE 443 443
