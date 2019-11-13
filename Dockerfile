ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

# 替换源来加速。有个会报错，先不用吧。将docker走代理了。。
#COPY ./resources/sources.list /etc/apt/

RUN apt-get update \
    && apt-get install -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql zip gd opcache bcmath

# 安装 php-redis 扩展。ADD 会复制并自动解压
WORKDIR /tmp
ADD ./resources/redis-5.1.1.tgz .
RUN mkdir -p /usr/src/php/ext \
    && mv redis-5.1.1 /usr/src/php/ext/redis \
    && docker-php-ext-install redis

CMD php-fpm
