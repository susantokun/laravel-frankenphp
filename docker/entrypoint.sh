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
mkdir -p storage/app/public storage/logs
php artisan storage:link || true
chown -R www-data:www-data storage || true
exec "$@"
