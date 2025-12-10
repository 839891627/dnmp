ARG PHP_VERSION=7.2
FROM php:${PHP_VERSION}-fpm

# 设置工作目录
WORKDIR /var/www

# 配置 Debian 归档镜像（Debian Buster 已 EOL，需要使用归档镜像）
# PHP 7.2 基于 Debian Buster，需要配置归档镜像源
RUN set -eux; \
    # 检测是否为 Debian Buster \
    if grep -q 'buster' /etc/os-release 2>/dev/null || ([ -f /etc/debian_version ] && grep -q '^10' /etc/debian_version 2>/dev/null); then \
        echo "配置 Debian Buster 归档镜像源..."; \
        # 备份原始 sources.list \
        cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true; \
        # 替换为归档镜像源 \
        sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list; \
        sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list; \
        # 更新 sources.list.d 中的文件 \
        if [ -d /etc/apt/sources.list.d ]; then \
            for file in /etc/apt/sources.list.d/*.list; do \
                [ -f "$file" ] && sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' "$file" || true; \
                [ -f "$file" ] && sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' "$file" || true; \
            done; \
        fi; \
    fi

# 安装系统依赖和 PHP 扩展依赖
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libzip-dev \
        libbz2-dev \
        unzip \
        && \
    # 配置和安装 PHP 扩展 \
    # PHP 7.2 使用旧的配置选项格式 \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        zip \
        gd \
        opcache \
        bcmath \
        pcntl \
        sockets \
    && \
    # 清理 apt 缓存
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 安装 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && \
    chmod +x /usr/local/bin/composer

# 安装 Redis 扩展（从源码）
WORKDIR /tmp
COPY ./resources/redis-5.1.1.tgz /tmp/
RUN mkdir -p /usr/src/php/ext && \
    tar -xzf redis-5.1.1.tgz && \
    mv redis-5.1.1 /usr/src/php/ext/redis && \
    docker-php-ext-install redis && \
    rm -rf /tmp/redis-5.1.1.tgz

# 安装其他扩展（按需启用）
# MongoDB 扩展
COPY ./resources/mongodb-1.6.0.tgz /tmp/
RUN tar -xzf mongodb-1.6.0.tgz && \
    cd mongodb-1.6.0 && \
    phpize && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf mongodb-1.6.0 mongodb-1.6.0.tgz && \
    docker-php-ext-enable mongodb || true

# Xdebug 扩展
COPY ./resources/xdebug-3.0.1.tgz /tmp/
RUN tar -xzf xdebug-3.0.1.tgz && \
    cd xdebug-3.0.1 && \
    phpize && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf xdebug-3.0.1 xdebug-3.0.1.tgz && \
    docker-php-ext-enable xdebug || true

# 可选：安装 Node.js（按需启用）
# COPY ./resources/node-v14.18.1-linux-x64.tar.xz /tmp/
# RUN tar -xf node-v14.18.1-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
#     rm -f /tmp/node-v14.18.1-linux-x64.tar.xz

# 可选：安装 Python（按需启用）
# COPY ./resources/Python-2.7.18.tar.xz /tmp/
# RUN tar -xf Python-2.7.18.tar.xz && \
#     cd Python-2.7.18 && \
#     ./configure && \
#     make -j$(nproc) && \
#     make install && \
#     cd .. && \
#     rm -rf Python-2.7.18 Python-2.7.18.tar.xz

# 可选：安装 Swoole（按需启用）
# COPY ./resources/swoole-src-4.4.12.zip /tmp/
# RUN unzip -q swoole-src-4.4.12.zip && \
#     cd swoole-src-4.4.12 && \
#     phpize && \
#     ./configure && \
#     make -j$(nproc) && \
#     make install && \
#     cd .. && \
#     rm -rf swoole-src-4.4.12 swoole-src-4.4.12.zip && \
#     docker-php-ext-enable swoole || true

# 清理临时文件
RUN rm -rf /tmp/* /var/tmp/*

# 设置工作目录
WORKDIR /var/www

# 设置默认命令
CMD ["php-fpm"]
