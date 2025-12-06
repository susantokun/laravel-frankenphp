#!/bin/sh
set -e

APP_PORT=${APP_INTERNAL_PORT:-8000}

if [ -n "$APP_DOMAIN" ]; then
  cat > /etc/caddy/Caddyfile <<EOF
{
    email ${ACME_EMAIL}
}

${APP_DOMAIN} {
    encode gzip
    reverse_proxy laravel_frankenphp:${APP_PORT}
}
EOF
else
  cat > /etc/caddy/Caddyfile <<EOF
{
    auto_https off
}

:80 {
    encode gzip
    reverse_proxy laravel_frankenphp:${APP_PORT}
}
EOF
fi

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
