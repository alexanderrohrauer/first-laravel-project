#!/bin/sh
set -e

# Build config/route/view/event caches from the runtime environment.
php artisan optimize

# Scaleway containers scale horizontally, so run migrations only when asked to
# (set RUN_MIGRATIONS=true on the container, ideally with max-scale=1 during a migrating deploy).
if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
    php artisan migrate --force
fi

exec "$@"
