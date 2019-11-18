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

ADD ./resources/redis-5.1.1.tgz .
ADD ./resources/Python-3.8.0.tgz .
ADD ./resources/node-v12.13.0-linux-x64.tar.xz .

# 安装 redis 扩展
RUN mkdir -p /usr/src/php/ext \
    && mv /tmp/redis-5.1.1 /usr/src/php/ext/redis \
    && docker-php-ext-install redis

# 安装 python3
RUN cd /tmp/Python-3.8.0 && ./configure && make && make install && rm -rf /tmp/Python-3.8.0 Python-3.8.0.tgz

# 安装 nodejs
RUN ln -s /tmp/node-v12.13.0-linux-x64/bin/node /usr/bin/node \
    && ln -s /tmp/node-v12.13.0-linux-x64/bin/npm /usr/bin/npm

CMD php-fpm
