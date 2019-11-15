ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

# 替换源来加速。有个会报错，先不用吧。将docker走代理了。。
#COPY ./resources/sources.list /etc/apt/

RUN apt-get update \
    && apt-get install -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql zip gd opcache bcmath \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

WORKDIR /tmp

# 安装 php-redis 扩展。ADD 会复制并自动解压
ADD ./resources/redis-5.1.1.tgz .
RUN mkdir -p /usr/src/php/ext \
    && mv redis-5.1.1 /usr/src/php/ext/redis \
    && docker-php-ext-install redis

# 安装 node(npm) 前端后期问题太多了，直接宿主机安装
ADD ./resources/node-v12.13.0-linux-x64.tar.xz .
RUN ln -s /tmp/node-v12.13.0-linux-x64/bin/node /usr/bin/node \
    && ln -s /tmp/node-v12.13.0-linux-x64/bin/npm /usr/bin/npm

CMD php-fpm
