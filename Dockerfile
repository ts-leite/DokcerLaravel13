FROM php:8.4-fpm-bookworm

ARG APP_UID=1000
ARG APP_GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    && docker-php-ext-install -j"$(nproc)" \
    pdo_pgsql \
    pgsql \
    mbstring \
    bcmath \
    pcntl \
    intl \
    zip \
    opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Ajusta o usuário www-data para os IDs configurados no build.
RUN groupmod -o -g "${APP_GID}" www-data \
    && usermod -o -u "${APP_UID}" -g "${APP_GID}" www-data

WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm"]