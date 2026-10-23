FROM alpine:3.22

LABEL description="Simple forum software for building great communities" \
      maintainer="kitbur <https://github.com/kitbur>"

ARG FLARUM_VERSION="v2.0.2"

ENV GID=991 \
    UID=991 \
    UPLOAD_MAX_SIZE=50M \
    PHP_MEMORY_LIMIT=128M \
    OPCACHE_MEMORY_LIMIT=128M \
    DB_HOST=mariadb \
    DB_USER=flarum \
    DB_NAME=flarum \
    DB_PORT=3306 \
    FLARUM_TITLE="Docker-Flarum" \
    DEBUG=false \
    LOG_TO_STDOUT=false \
    GITHUB_TOKEN_AUTH=false \
    FLARUM_PORT=8888

RUN apk add --no-progress --no-cache \
    curl \
    git \
    icu-data-full \
    libcap \
    nginx \
    php84 \
    php84-ctype \
    php84-curl \
    php84-dom \
    php84-exif \
    php84-fileinfo \
    php84-fpm \
    php84-gd \
    php84-gmp \
    php84-iconv \
    php84-intl \
    php84-mbstring \
    php84-mysqlnd \
    php84-opcache \
    php84-pecl-apcu \
    php84-openssl \
    php84-pdo \
    php84-pdo_mysql \
    php84-phar \
    php84-session \
    php84-tokenizer \
    php84-xmlwriter \
    php84-zip \
    php84-zlib \
    su-exec \
    s6 \
    s6-overlay

RUN ln -s /usr/bin/php84 /usr/bin/php

RUN cd /tmp \
  && curl --progress-bar https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer

RUN sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php84/php.ini \
  && mkdir -p /run/php /flarum/app

RUN COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum:${FLARUM_VERSION} /flarum/app --stability=beta --no-install \
  && cd /flarum/app \
  && composer require "flarum/core:${FLARUM_VERSION}" --no-update \
  && COMPOSER_CACHE_DIR="/tmp" composer install --prefer-dist --no-dev --no-plugins \
  && composer clear-cache \
  && rm -rf /flarum/.composer /tmp/*

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx

COPY rootfs /

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/run /etc/s6.d/.s6-svscan/*

VOLUME /flarum/app/public/assets \
       /flarum/app/storage/logs \
       /flarum/app/packages

CMD ["/usr/local/bin/startup"]
