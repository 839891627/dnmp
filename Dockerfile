ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

# 替换成 清华大学源加速。真快
COPY ./resources/sources.list /etc/apt/

# 安装 composer 以及一些 php 扩展
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev libzip-dev unzip\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/  --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_mysql zip gd opcache bcmath pcntl sockets

WORKDIR /tmp

# 安装 redis 扩展
ADD ./resources/redis-5.1.1.tgz .
RUN mkdir -p /usr/src/php/ext \
    && mv /tmp/redis-5.1.1 /usr/src/php/ext/redis \
    && docker-php-ext-install redis

# 以下注释按需打开（某些项目需要 npm 啥的）
# 安装 python3
ADD ./resources/Python-2.7.18.tar.xz .
RUN cd /tmp/Python-2.7.18 && ./configure && make && make install && rm -rf /tmp/Python-2.7.18 Python-2.7.18.tar.xz

# 安装 nodejs
ADD ./resources/node-v14.18.1-linux-x64.tar.xz .
RUN ln -s /tmp/node-v14.18.1-linux-x64/bin/node /usr/bin/node \
    && ln -s /tmp/node-v14.18.1-linux-x64/bin/npm /usr/bin/npm

# 安装 swoole
#COPY ./resources/swoole-src-4.4.12.zip .
#RUN cd /tmp && unzip swoole-src-4.4.12.zip \
#    && cd swoole-src-4.4.12 && phpize && ./configure \
#    && make && make install && rm -rf /tmp/swoole*

ADD ./resources/mcrypt-1.0.3.tgz .
RUN cd /tmp/mcrypt-1.0.3 && phpize && ./configure && make && make install && rm -rf /tmp/mcrypt-1.0.3

ADD ./resources/mongodb-1.6.0.tgz .
RUN cd /tmp/mongodb-1.6.0 && phpize && ./configure && make && make install && rm -rf /tmp/mongodb-1.6.0

ADD ./resources/xdebug-3.0.1.tgz .
RUN cd /tmp/xdebug-3.0.1 && phpize && ./configure && make && make install && rm -rf /tmp/xdebug-3.0.1

CMD php-fpm
