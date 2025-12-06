FROM dunglas/frankenphp:php8.2

ENV SERVER_NAME=:80

WORKDIR /app

COPY --chown=www-data:www-data . /app

COPY . /app

RUN apt update && apt install -y zip libzip-dev && \
    docker-php-ext-install zip pcntl && \
    docker-php-ext-enable zip

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

RUN composer install && \
    composer require laravel/octane && \
    php artisan octane:install --server=frankenphp

EXPOSE 8000

CMD php artisan octane:start --server=frankenphp --host=0.0.0.0 --port=8000
