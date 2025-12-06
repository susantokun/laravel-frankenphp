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
  cp -f .env.production .env
fi
exec "$@"
