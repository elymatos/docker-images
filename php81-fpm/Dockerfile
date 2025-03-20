FROM php:8.1-fpm

USER root

# Run apt update
RUN apt-get -y update
#RUN apt-get upgrade -y

# Install useful tools and libraries
RUN apt-get install -y libcurl4 libcurl4-openssl-dev libzip-dev libicu-dev libonig-dev
RUN apt-get install -y apt-utils build-essential nano wget dialog git curl zip unzip
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev dnsutils

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN pear config-set php_ini "$PHP_INI_DIR/php.ini"

# XDebug
RUN pecl install xdebug

# PHP DS
RUN pecl install ds

# Other extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install zip
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install opcache
RUN docker-php-ext-install mbstring

RUN mkdir -p /usr/src/php/ext/apcu && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 && docker-php-ext-install apcu
RUN docker-php-ext-configure gd
RUN docker-php-ext-install -j$(nproc) gd

RUN mkdir -m=1777 -p /tmp/.opcache
RUN echo "opcache.enable=1;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.memory_consumption=64;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.interned_strings_buffer=8;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.max_accelerated_files=3000;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.revalidate_freq=180;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.fast_shutdown=0;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.enable_cli=0;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.revalidate_path=0;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.validate_timestamps=1;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.max_file_size=0;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.file_cache=/tmp/.opcache;" >> "$PHP_INI_DIR/php.ini" \
    && echo "opcache.file_cache_only=1;" >> "$PHP_INI_DIR/php.ini"

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -m=0644 /var/log/orkester
RUN chown www-data:www-data /var/log/orkester
