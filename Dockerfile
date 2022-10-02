FROM php:8.1-fpm-alpine

WORKDIR /app

RUN apk update; \
    apk add --no-cache \
        libmemcached-dev \
        zlib-dev \
        libpq-dev \
        jpeg-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        freetype-dev \
        libwebp-dev \
        libxpm-dev \
        libmcrypt-dev \
        oniguruma-dev \
        libedit \
        pcre2 \
        nodejs \
        npm \
        nginx \
        supervisor;

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql; \
    # Install the PHP pdo_pgsql extention
    docker-php-ext-install pdo_pgsql; \
    # Install PHP bcmath extension
    docker-php-ext-install bcmath; \
    # Install PHP opcache extension
    docker-php-ext-install opcache; \
    # Install the PHP gd library
    docker-php-ext-configure gd \
            --prefix=/usr \
            --with-jpeg \
            --with-webp \
            --with-xpm \
            --with-freetype; \
    docker-php-ext-install gd; \
    php -r 'var_dump(gd_info());'

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer;

# Copy configuration files
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf

ENTRYPOINT [ "/app/docker/entrypoint.sh" ]

EXPOSE 80