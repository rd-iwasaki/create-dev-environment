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

# PHPの設定ファイル（php.ini）をコピー
COPY php/php.ini /usr/local/etc/php/php.ini

# コンテナ起動時に実行されるスクリプトをコピー
COPY ./scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# コンテナ起動時に実行
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]