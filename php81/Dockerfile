# Base image
FROM php:8.1-apache

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

USER root

# Run apt update
RUN apt-get -y update
#RUN apt-get upgrade -y

# Install useful tools and libraries
RUN apt-get -y install libcurl4 libcurl4-openssl-dev mariadb-client libzip-dev  libicu-dev libonig-dev
RUN apt-get -y install apt-utils build-essential nano wget dialog git curl zip unzip
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /opt/php-libs
# Install xdebug 3.0
COPY ./xdebug.ini /opt/php-libs
# Copy xdebug configuration for remote debugging
RUN cd /opt/php-libs \
    && git clone https://github.com/xdebug/xdebug \
    && cd xdebug \
    # the last working commit, because the php-src is not up to date yet in this alpine
    && phpize \
    && ./configure --enable-xdebug-dev \
    && make all \
    && mv /opt/php-libs/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install ds
RUN cd /opt/php-libs \
    && git clone https://github.com/php-ds/extension "php-ds" \
    && cd php-ds \
    # the last working commit, because the php-src is not up to date yet in this alpine
    && phpize \
    && ./configure \
    && make \
    && make install \
# Clean up the build files
    && make clean \
    && phpize --clean \
    && echo "extension = ds.so" >> /usr/local/etc/php/conf.d/docker-php-ext-ds.ini

# Other PHP8 Extensions

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install zip
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install sockets
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install opcache

RUN mkdir -p /usr/src/php/ext/apcu && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 && docker-php-ext-install apcu 
RUN docker-php-ext-configure gd
RUN docker-php-ext-install -j$(nproc) gd
#RUN docker-php-ext-install ds

RUN mkdir -p /tmp/.opcache
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

ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable mod_rewrite
RUN a2enmod rewrite headers

#
# Python3
#

ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update && apt-get install -y --no-install-recommends \
		libbluetooth-dev \
		tk-dev \
		uuid-dev \
		libssl-dev \
		gnupg \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY A035C8C19219BA821ECEA86B64E628F8D684696D
ENV PYTHON_VERSION 3.11.0a2

RUN set -ex \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-lto \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
		\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 21.3.1
# https://github.com/docker-library/python/issues/365
ENV PYTHON_SETUPTOOLS_VERSION 57.5.0
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/3cb8888cc2869620f57d5d2da64da38f516078c7/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 c518250e91a70d7b20cceb15272209a4ded2a0c263ae5776f129e0d9b5674309

RUN set -ex; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	python get-pip.py --verbose \
	    --trusted-host pypi.org --trusted-host files.pythonhosted.org \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
		"setuptools==$PYTHON_SETUPTOOLS_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py
