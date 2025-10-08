FROM php:8.4-apache
ARG arg

# https://github.com/asimlqt/docker-php/blob/master/apache/8.4/Dockerfile

# Ferramentas básicas para o funcionamento
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get install -y vim \
    && apt-get install -y net-tools \
    && apt-get install -y wget \
    && apt-get install -y fontconfig \
    && apt-get install -y curl \
    && apt-get install -y ca-certificates

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite

# Instalar dependências de sistema para extensões PHP
RUN apt-get update \
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
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Configurar e instalar extensões PHP principais
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure bz2 \
    && docker-php-ext-configure soap \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
    exif \
    gd \
    gmp \
    iconv \
    intl \
    mbstring \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    xml \
    zip

# Instalar Redis via PECL (versão mais recente compatível com PHP 8.4)
RUN pecl install redis \
    && docker-php-ext-enable redis

# Instalar Composer mais recente
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Instalar Git e ferramentas de versionamento
RUN apt-get update \
    && apt-get install -y git subversion mercurial \
    && rm -rf /var/lib/apt/lists/*

# Instalar Xdebug (apenas para desenvolvimento)
RUN if test "$arg" = "develop" ; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ; \
    fi

# --------------------------------
# Instalando OpenJDK 11 (versão mais recente e estável)
# --------------------------------
# Dependências para funcionar o relatório
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    fontconfig \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

# Configurar JAVA_HOME
ENV JAVA_HOME=/usr/local/openjdk-8
COPY --from=accellogdev/openjdk-8u222:v1.0 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# -------------------------------- Fim instalando JDK

# Copiando php.ini default da Accellog
COPY php.ini-production /usr/local/etc/php/php.ini

# Configurações de permissões
RUN chmod 777 -R /var/www \
    && chmod 777 -R /tmp

# Limpeza final
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configurações recomendadas de segurança
RUN echo "ServerTokens Prod" >> /etc/apache2/conf-available/security.conf \
    && echo "ServerSignature Off" >> /etc/apache2/conf-available/security.conf \
    && a2enconf security

EXPOSE 80

WORKDIR /var/www/html
