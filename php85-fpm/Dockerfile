FROM php:8.5-fpm-alpine

ARG PROD

RUN apk add -U --no-cache \
    linux-headers \
    autoconf \
    imap-dev \
    libpng-dev \
    zlib-dev \
    libjpeg-turbo-dev \
    krb5-dev \
    openssl-dev \
    libzip-dev \
    oniguruma-dev \
    make \
    g++ \
    git \
    bash \
    fish

RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install \
    -j$(nproc) gd \
    pdo_mysql \
    pcntl \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's#variables_order = "GPCS"#variables_order = "EGPCS"#g' $PHP_INI_DIR/php.ini \
    && echo "memory_limit = 128M" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "post_max_size = 1000M" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "upload_max_filesize = 1000M" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "max_execution_time = 4000" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "pm.max_children=32" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && pecl install ds \
    && docker-php-ext-enable ds \
    && pecl install redis \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable pcntl \
    && echo "apc.enable_cli=1" >> "$PHP_INI_DIR/php.ini" \
    && echo "apc.enable=1" >> "$PHP_INI_DIR/php.ini"


COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN if [[ -n "$PROD" ]] ; then composer install; fi

WORKDIR /www
