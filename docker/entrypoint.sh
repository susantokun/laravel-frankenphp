#!/bin/sh
set -e
if [ -f .env.production.encrypted ] && [ ! -f .env.production ]; then
  if [ -z "$ENV_ENCRYPTION_KEY" ]; then
    echo "ENV_ENCRYPTION_KEY is not set; cannot decrypt .env.production.encrypted" >&2
    exit 1
  fi
  php artisan env:decrypt --env=production --key="$ENV_ENCRYPTION_KEY"
fi
if [ -f .env.production ]; then
  if [ -f .env ]; then
    rm -f .env
  fi
  cp -f .env.production .env
fi
if [ ! -f config/octane.php ]; then
  php artisan octane:install --server=frankenphp || true
fi
if [ ! -f config/horizon.php ]; then
  php artisan horizon:install || true
fi
php artisan optimize:clear || true
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true
php artisan event:cache || true
mkdir -p storage/app/public storage/logs
php artisan storage:link || true
chown -R www-data:www-data storage || true
exec "$@"
