FROM php:${PHP_VERSION}-apache

# 必要なPHP拡張機能をインストール
RUN docker-php-ext-install pdo_mysql

# Apacheの設定
RUN a2enmod rewrite
