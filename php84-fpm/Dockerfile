FROM php:8.4-fpm-alpine

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
    libuv-dev \
    make \
    g++ \
    git \
    bash \
    fish \
    icu-dev \
    icu-data-full \
    brotli-dev \
    dotnet9-runtime

RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install \
    -j$(nproc) gd \
    zip \
    opcache \
    fileinfo \
    mbstring \
    pdo_mysql \
    pcntl \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's#;opcache.enable=1#opcache.enable=1#g' $PHP_INI_DIR/php.ini \
    && sed -i 's#variables_order = "GPCS"#variables_order = "EGPCS"#g' $PHP_INI_DIR/php.ini \
    && sed -i 's#memory_limit = 128M#memory_limit = 1000M#g' $PHP_INI_DIR/php.ini \
    && echo "post_max_size = 1000M" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "upload_max_filesize = 1000M" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "max_execution_time = 4000" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "opcache.file_cache=/www/opcache" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && echo "pm.max_children=32" >> /usr/local/etc/php/conf.d/docker-fpm.ini \
    && pecl install ds \
    && docker-php-ext-enable ds \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && pecl install grpc \
    && docker-php-ext-enable grpc \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && echo "apc.enable_cli=1" >> "$PHP_INI_DIR/php.ini" \
    && echo "apc.enable=1" >> "$PHP_INI_DIR/php.ini" \
    && pecl install swoole \
    && docker-php-ext-enable swoole \
    && pecl install "uv-0.3.0" \
    && docker-php-ext-enable uv \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl


COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN if [[ -n "$PROD" ]] ; then composer install; fi

WORKDIR /www
