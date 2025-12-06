FROM dunglas/frankenphp:php8.2

ENV SERVER_NAME=:80

WORKDIR /app

COPY --chown=www-data:www-data . /app

RUN chown -R www-data:www-data /app

RUN apt-get update && apt-get install -y --no-install-recommends \
        zip \
        unzip \
        curl \
        libzip-dev \
        zlib1g-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pcntl \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install redis \
    && docker-php-ext-enable redis

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader && \
    composer require laravel/octane && \
    php artisan octane:install --server=frankenphp

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000

USER www-data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sh","-lc","php artisan octane:start --server=frankenphp --host=0.0.0.0 --port=${APP_INTERNAL_PORT:-8000}"]
