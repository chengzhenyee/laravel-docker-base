FROM php:8.1-fpm

LABEL maintainer="Cheng Zhen Yee <chengzhenyee@gmail.com>"

WORKDIR /app

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            supervisor \
            nginx \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            libwebp-dev \
            libxpm-dev \
            libmcrypt-dev \
            libonig-dev \
            zip \
            unzip; \
    rm -rf /var/lib/apt/lists/*

# Install the PHP extensions
RUN docker-php-ext-install \
            opcache \
            pdo_mysql \
            pdo_pgsql \
            bcmath; \
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

# Install NodeJS v16 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt install nodejs -y;

# Copy configuration files
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY nginx.conf /etc/nginx/sites-available/default
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf