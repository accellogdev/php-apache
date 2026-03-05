FROM php:8.5-apache
ARG arg

# https://github.com/asimlqt/docker-php/blob/master/apache/8.5/Dockerfile

# ferramentas básicas para o funcionamento
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get install -y vim \
    && apt-get install -y net-tools \
    && apt-get install -y wget \
    && apt-get install -y fontconfig

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
    && docker-php-ext-install -j$(nproc) bcmath exif iconv intl mysqli pdo_mysql zip bz2 \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd soap mbstring \
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

# instalando git
RUN apt-get update \
    && apt-get install -y git subversion mercurial

# Install xdebug
RUN if test "$arg" = "develop" ; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ; \
    fi

# # --------------------------------
# # instalando JDK
# # --------------------------------    
## dependências para funcionar o relatório
RUN apt-get update; \
    apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
		dirmngr \
        p11-kit \
		fontconfig libfreetype6;

ENV JAVA_HOME=/usr/local/openjdk-8
COPY --from=accellogdev/openjdk-8u222:v1.0 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# # -------------------------------- fim instalando JDK

# Copiando php.ini default da Accellog
COPY php.ini-production /usr/local/etc/php/php.ini

RUN chmod 777 -R /var/www
RUN chmod 777 -R /tmp