FROM php:8.1-fpm-alpine3.19 as php

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN set -eux \
    && apk add --no-cache \
    unzip \
    zip \
    git \
    curl \
    dos2unix \
    nodejs \
    npm \
    redis \
    supervisor \
    ca-certificates \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions gd zip pdo_mysql exif opcache redis

RUN addgroup -g 1000 -S kdock \
    && adduser -u 1000 -D -G kdock kdock

RUN apk add \
    --no-cache \
    --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
    --virtual .shadow-deps \
    shadow \
    && groupmod -o -g 1000 www-data \
    && usermod -o -u 1000 -g www-data www-data \
    && apk del .shadow-deps

# Add composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN mkdir -p /var/www/.composer \
    && chown kdock:kdock -R /var/www/.composer

# Prepare supervisor
RUN rm -rf /var/log/supervisor ; mkdir -m 777 /var/log/supervisor
COPY ./build/supervisor/ /etc/supervisor/conf.d/


# Custom entrypoint to run fpm or other
COPY ./build/php/init.sh /
RUN dos2unix /init.sh && chmod +x /init.sh

# Custom entrypoint to run fpm or other
COPY ./build/php/entrypoint.sh /
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

# Set working directory
WORKDIR /app

ENTRYPOINT ["/bin/sh", "-c"]

CMD ["/entrypoint.sh","/supervisor.sh"]

#
# Production build
#
FROM php as production

ARG COMPOSER_AUTH

COPY ./app/composer.json /app/composer.json
COPY ./app/composer.lock /app/composer.lock

# Install dependencies using Composer
RUN composer install --no-cache --no-interaction --prefer-dist --no-plugins --no-scripts --no-dev --no-autoloader --ansi

# Copy existing application directory contents and change
# ownership of the application files
COPY ./app /app

# Finish composer
RUN composer dump-autoload --no-dev --optimize --ansi

#RUN php artisan route:cache
RUN php artisan view:cache

RUN chown -R kdock:kdock /app
