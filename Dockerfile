FROM php:8.2-apache
ARG arg

# https://github.com/asimlqt/docker-php/blob/master/apache/8.2/Dockerfile

# ferramentas básicas para o funcionamento
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get install -y vim \
    && apt-get install -y net-tools \
    && apt-get install -y wget

RUN set -x \
    && a2enmod rewrite \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libssl-dev \
        libicu-dev \
        libbz2-dev \
        libssh2-1-dev \
        libgmp-dev \
        libpq-dev \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
    && docker-php-ext-install -j$(nproc) bcmath exif iconv intl mysqli opcache pdo_mysql zip \
    && docker-php-ext-configure bz2 --with-bz2=/usr/include/ \
    && docker-php-ext-install -j$(nproc) bz2 \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd bcmath xml soap mbstring \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pgsql pdo_pgsql \
    && docker-php-ext-install -j$(nproc) gmp 

RUN apt-get update \
&& apt-get install -y libpq-dev \
&& docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
&& docker-php-ext-install pdo pdo_pgsql pgsql

# instalando Redis
RUN pecl install redis \
	&& docker-php-ext-enable redis

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer


# Install xdebug
RUN if test "$arg" = "develop" ; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ; \
    fi

# Install Java Open JDK 8
# RUN apt-get install -y openjdk-8-jdk
# ENV JAVA_HOME=/opt/java/openjdk
# COPY --from=eclipse-temurin:8u382-b05-jdk $JAVA_HOME $JAVA_HOME
# ENV PATH="${JAVA_HOME}/bin:${PATH}"
# ENV JAVA_HOME=/usr/local/openjdk-8
# COPY --from=openjdk:8.222 $JAVA_HOME $JAVA_HOME
# ENV PATH="${JAVA_HOME}/bin:${PATH}"

# --------------------------------
# instalando JDK
# --------------------------------
# https://hub.docker.com/_/openjdk
# https://github.com/docker-library/openjdk
# RUN set -eux; \
RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        bzip2 \
        unzip \
        xz-utils \
        gpg \
        gpg-agent \
        dirmngr \
        ca-certificates p11-kit \
        fontconfig libfreetype6;

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_HOME /usr/local/openjdk-8
ENV PATH $JAVA_HOME/bin:$PATH

# backwards compatibility shim
RUN { echo '#/bin/sh'; echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# https://adoptopenjdk.net/upstream.html
# ENV JAVA_VERSION 8u222
# ENV JAVA_BASE_URL https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jdk_
# ENV JAVA_URL_VERSION 8u222b10
ENV JAVA_VERSION 8u342
ENV JAVA_BASE_URL https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u342-b07/OpenJDK8U-jdk_
ENV JAVA_URL_VERSION 8u342b07
# https://github.com/docker-library/openjdk/issues/320#issuecomment-494050246

# RUN set -eux; \
# 	\
RUN	dpkgArch="$(dpkg --print-architecture)"; \
    case "$dpkgArch" in \
        amd64) upstreamArch='x64' ;; \
        arm64) upstreamArch='aarch64' ;; \
        *) echo >&2 "error: unsupported architecture: $dpkgArch" ;; \
    esac; \
    \
    wget -O openjdk.tgz.asc "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz.sign"; \
    wget -O openjdk.tgz "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz" --progress=dot:giga; \
    \
    export GNUPGHOME="$(mktemp -d)"; \
# TODO find a good link for users to verify this key is right (https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2019-April/000951.html is one of the only mentions of it I can find); perhaps a note added to https://adoptopenjdk.net/upstream.html would make sense?
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys CA5F11C6CE22644D42C6AC4492EF8D39DC13168F; \
# https://github.com/docker-library/openjdk/pull/322#discussion_r286839190
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys EAC843EBD3EFDB98CC772FADA5CD6035332FA671; \
    gpg --batch --list-sigs --keyid-format 0xLONG CA5F11C6CE22644D42C6AC4492EF8D39DC13168F | grep '0xA5CD6035332FA671' | grep 'Andrew Haley'; \
    gpg --batch --verify openjdk.tgz.asc openjdk.tgz; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"; \
    \
    mkdir -p "$JAVA_HOME"; \
    tar --extract \
        --file openjdk.tgz \
        --directory "$JAVA_HOME" \
        --strip-components 1 \
        --no-same-owner \
    ; \
    rm openjdk.tgz*; \
    \
# TODO strip "demo" and "man" folders?
    \
# update "cacerts" bundle to use Debian's CA certificates (and make sure it stays up-to-date with changes to Debian's store)
# see https://github.com/docker-library/openjdk/issues/327
#     http://rabexc.org/posts/certificates-not-working-java#comment-4099504075
#     https://salsa.debian.org/java-team/ca-certificates-java/blob/3e51a84e9104823319abeb31f880580e46f45a98/debian/jks-keystore.hook.in
#     https://git.alpinelinux.org/aports/tree/community/java-cacerts/APKBUILD?id=761af65f38b4570093461e6546dcf6b179d2b624#n29
    { \
        echo '#!/usr/bin/env bash'; \
        echo 'set -Eeuo pipefail'; \
        echo 'if ! [ -d "$JAVA_HOME" ]; then echo >&2 "error: missing JAVA_HOME environment variable"; exit 1; fi'; \
# 8-jdk uses "$JAVA_HOME/jre/lib/security/cacerts" and 8-jre and 11+ uses "$JAVA_HOME/lib/security/cacerts" directly (no "jre" directory)
        echo 'cacertsFile=; for f in "$JAVA_HOME/lib/security/cacerts" "$JAVA_HOME/jre/lib/security/cacerts"; do if [ -e "$f" ]; then cacertsFile="$f"; break; fi; done'; \
        echo 'if [ -z "$cacertsFile" ] || ! [ -f "$cacertsFile" ]; then echo >&2 "error: failed to find cacerts file in $JAVA_HOME"; exit 1; fi'; \
        echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$cacertsFile"'; \
    } > /etc/ca-certificates/update.d/docker-openjdk; \
    chmod +x /etc/ca-certificates/update.d/docker-openjdk; \
    /etc/ca-certificates/update.d/docker-openjdk; \
    \
# https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
    find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig; \
    \
# basic smoke test
    javac -version; \
    java -version
# -------------------------------- fim instalando JDK

# Copiando php.ini default da Accellog
COPY php.ini-production /usr/local/etc/php/php.ini

RUN chmod 777 -R /var/www
RUN chmod 777 -R /tmp