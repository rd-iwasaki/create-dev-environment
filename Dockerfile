# Dockerfile

# ベースイメージを動的に指定
ARG PHP_VERSION
FROM php:${PHP_VERSION}-apache

# 必要なPHP拡張機能をインストール
RUN docker-php-ext-install -j$(nproc) pdo_mysql

# 追加のツールをインストール（git, zip, unzipなど）
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libicu-dev

# Composerをインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Apacheの設定
RUN a2enmod rewrite

# コンテナ起動時に実行
CMD ["apache2-foreground"]