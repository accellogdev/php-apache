FROM php:8.2-apache
ARG arg

# https://github.com/asimlqt/docker-php/blob/master/apache/8.2/Dockerfile

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

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# --------------------------------
# instalando JDK
# --------------------------------
# https://hub.docker.com/_/openjdk
# https://github.com/docker-library/openjdk
RUN set -eux; \
	apt-get update; \
    apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
	# gpg and dirmngr
		gpg \
		dirmngr \
		\
	# utilities for keeping Debian and OpenJDK CA certificates in sync
		ca-certificates p11-kit \
		\
	# java.lang.UnsatisfiedLinkError: /usr/local/openjdk-11/lib/libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
	# java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
	# https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
		fontconfig libfreetype6 \
	;

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_HOME /usr/local/openjdk-8
ENV PATH $JAVA_HOME/bin:$PATH

# backwards compatibility shim
RUN { echo '#/bin/sh'; echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# https://adoptopenjdk.net/upstream.html
ENV JAVA_VERSION 8u222
ENV JAVA_BASE_URL https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jdk_
ENV JAVA_URL_VERSION 8u222b10
# https://github.com/docker-library/openjdk/issues/320#issuecomment-494050246

# Install xdebug
RUN if [[ test "$arg" = "develop" ]] ; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Java Open JDK 8
# RUN apt-get install -y openjdk-8-jdk
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:8u382-b05-jdk $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN chmod 777 -R /var/www
RUN chmod 777 -R /tmp