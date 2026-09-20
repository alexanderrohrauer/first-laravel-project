# syntax=docker/dockerfile:1

# ---- Base: FrankenPHP with the extensions the app needs ----
FROM dunglas/frankenphp:1-php8.4 AS base

RUN install-php-extensions \
    bcmath \
    exif \
    gd \
    intl \
    opcache \
    pcntl \
    pdo_pgsql \
    zip

WORKDIR /app

# ---- Build: composer + node (Wayfinder needs PHP while Vite builds) ----
FROM base AS build

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=node:22-bookworm-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=node:22-bookworm-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=production \
    APP_KEY=base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA= \
    DB_CONNECTION=pgsql \
    CACHE_STORE=array \
    SESSION_DRIVER=array

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip git \
    && rm -rf /var/lib/apt/lists/*

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction

COPY package.json package-lock.json .npmrc ./
RUN npm ci

COPY . .
RUN composer dump-autoload --optimize --no-dev \
    && php artisan package:discover --ansi \
    && php artisan filament:assets \
    && npm run build \
    && rm -rf node_modules

# ---- Runtime ----
FROM base AS runtime

ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr \
    SERVER_NAME=:8080 \
    XDG_CONFIG_HOME=/tmp \
    XDG_DATA_HOME=/tmp

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY docker/php.ini "$PHP_INI_DIR/conf.d/zz-app.ini"

COPY --from=build --chown=www-data:www-data /app /app
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && setcap -r /usr/local/bin/frankenphp || true \
    && mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

USER www-data
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
    CMD curl -fsS http://localhost:8080/up || exit 1

ENTRYPOINT ["entrypoint.sh"]
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
