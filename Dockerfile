ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

# 替换源来加速
COPY ./resources/sources.list /etc/apt/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev libzip-dev unzip\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/  --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_mysql zip gd opcache bcmath pcntl sockets

WORKDIR /tmp

ADD ./resources/redis-5.1.1.tgz .
#ADD ./resources/Python-3.8.0.tgz .
#ADD ./resources/node-v12.13.0-linux-x64.tar.xz .
COPY ./resources/swoole-src-4.4.12.zip .

# 安装 redis 扩展
RUN mkdir -p /usr/src/php/ext \
    && mv /tmp/redis-5.1.1 /usr/src/php/ext/redis \
    && docker-php-ext-install redis

# 安装 python3
#RUN cd /tmp/Python-3.8.0 && ./configure && make && make install && rm -rf /tmp/Python-3.8.0 Python-3.8.0.tgz

# 安装 nodejs
#RUN ln -s /tmp/node-v12.13.0-linux-x64/bin/node /usr/bin/node \
#    && ln -s /tmp/node-v12.13.0-linux-x64/bin/npm /usr/bin/npm

# 安装 swoole
RUN cd /tmp && unzip swoole-src-4.4.12.zip \
    && cd swoole-src-4.4.12 && phpize && ./configure \
    && make && make install && rm -rf /tmp/swoole*

ADD ./resources/mcrypt-1.0.3.tgz .
ADD ./resources/mongodb-1.6.0.tgz .
ADD ./resources/xdebug-2.8.0.tgz .

RUN cd /tmp/mcrypt-1.0.3 && phpize && ./configure && make && make install && rm -rf /tmp/mcrypt-1.0.3
RUN cd /tmp/mongodb-1.6.0 && phpize && ./configure && make && make install && rm -rf /tmp/mongodb-1.6.0
RUN cd /tmp/xdebug-2.8.0 && phpize && ./configure && make && make install && rm -rf /tmp/xdebug-2.8.0

CMD php-fpm
