## 一、背景

这是一个基于 Docker 的 PHP 开发环境（DNMP: Docker + Nginx + MySQL + PHP），遵循 **"精简原则"**，尽量最小定制化，将定制工作交给使用者。通过简单的配置，提供灵活的开发环境。

## 二、特点

- ✅ **简单易用**：开箱即用，配置清晰
- ✅ **现代化**：兼容最新 Docker Compose 格式
- ✅ **灵活配置**：通过环境变量轻松调整版本和端口
- ✅ **性能优化**：使用缓存挂载，提升开发体验
- ✅ **多版本支持**：支持 PHP 7.2+、MySQL 5.7/8.0、Redis 等

## 三、功能说明

### 1. 目录结构说明

```
.
├── .env                    # 环境变量配置文件（需要从 env.example 复制）
├── env.example             # 环境变量配置示例文件
├── Dockerfile              # PHP 镜像构建脚本
├── docker-compose.yml      # Docker Compose 配置文件
├── config/
│   ├── nginx/              # Nginx 配置目录
│   │   └── conf.d/         # 站点配置文件（在此添加新项目配置）
│   ├── php/                # PHP 配置文件
│   │   ├── php72.ini       # PHP 7.2 配置
│   │   └── php73.ini       # PHP 7.3 配置
│   └── redis.conf         # Redis 配置文件
├── data/                   # 数据持久化目录
│   ├── composer/           # Composer 缓存
│   ├── mysql/              # MySQL 数据
│   └── redis/              # Redis 数据
├── logs/                   # 日志目录
│   └── nginx/              # Nginx 日志
└── resources/              # PHP 扩展源码包
    ├── redis-5.1.1.tgz
    ├── mongodb-1.6.0.tgz
    ├── xdebug-3.0.1.tgz
    └── ...
```

### 2. 集成的服务

- **PHP 7.2+** (FPM) - 支持多版本
- **Nginx** (Alpine) - Web 服务器
- **MySQL 8.0** - 数据库
- **Redis 7** - 缓存/会话存储
- **RabbitMQ** - 消息队列（可选）
- **SFTP** - 文件传输服务（可选）

## 四、快速开始

### 1. 环境准备

- Docker Desktop 或 Docker Engine 20.10+
- Docker Compose 2.0+

### 2. 配置环境变量

```bash
# 复制环境变量示例文件
cp env.example .env

# 编辑 .env 文件，根据实际情况修改配置
# 主要配置项：
# - WEB_ROOT: 项目根目录路径
# - PHP_VERSION: PHP 版本
# - MYSQL_ROOT_PASSWORD: MySQL root 密码
# - 各服务端口配置
```

### 3. 项目结构建议

建议将 DNMP 项目放在与其他开发项目的平级目录：

```
projects/
├── laravel/          # Laravel 项目
├── symfony/          # Symfony 项目
└── dnmp/             # 本环境（DNMP）
```

### 4. 启动服务

```bash
# 进入 dnmp 目录
cd dnmp

# 启动所有服务
docker compose up -d

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
```

### 5. 配置 Nginx

在 `config/nginx/conf.d/` 目录下添加站点配置文件，参考 `larave.conf` 示例。

### 6. 重启服务

```bash
# 重启所有服务
docker compose restart

# 重启单个服务（如 nginx）
docker compose restart nginx

# 重新构建 PHP 镜像
docker compose build php72
```

### 7. 项目配置

#### 配置 Hosts（可选）

在宿主机 `/etc/hosts` 文件中添加：

```
127.0.0.1 laravel.test
127.0.0.1 api.test
```

或者使用 dnsmasq（见附录）。

#### 项目数据库配置

在项目配置文件中使用容器名称作为主机名：

```ini
# Laravel .env 示例
DB_CONNECTION=mysql
DB_HOST=mysql          # 使用容器名，不是 127.0.0.1
DB_PORT=3306
DB_DATABASE=homestead
DB_USERNAME=homestead
DB_PASSWORD=secret

REDIS_HOST=redis        # 使用容器名
REDIS_PORT=6379
REDIS_PASSWORD=null
```


## 五、常用操作

### 1. 切换 PHP 版本

在 `docker-compose.yml` 中取消注释 `php73` 服务，然后：

```bash
# 启动 PHP 7.3 服务
docker compose up -d php73

# 在 Nginx 配置中修改 fastcgi_pass
# fastcgi_pass php73:9000;
```

### 2. 进入容器执行命令

```bash
# 进入 PHP 容器
docker compose exec php72 bash

# 在容器内执行 PHP 命令
docker compose exec php72 php -v
docker compose exec php72 composer install

# 在容器内执行 Composer
docker compose exec php72 composer require package/name
```

### 3. 安装 PHP 扩展

扩展已预装在 Dockerfile 中，如需添加新扩展：

1. 将扩展源码包放入 `resources/` 目录
2. 修改 `Dockerfile` 添加安装步骤
3. 重新构建镜像：`docker compose build php72`

查看已安装扩展：
```bash
docker compose exec php72 php -m
```

### 4. 查看日志

```bash
# 查看所有服务日志
docker compose logs

# 查看特定服务日志
docker compose logs nginx
docker compose logs php72
docker compose logs mysql

# 实时跟踪日志
docker compose logs -f nginx
```

### 5. 数据备份

```bash
# 备份 MySQL 数据
docker compose exec mysql mysqldump -u root -p --all-databases > backup.sql

# 备份 Redis 数据
docker compose exec redis redis-cli SAVE
cp data/redis/dump.rdb backup/
```

## 六、附录

### 1. 统一设置 .test 域名到本地（macOS）

使用 dnsmasq 可以自动将所有 `.test` 域名解析到本地：

```bash
# 安装 dnsmasq
brew install dnsmasq

# 配置 dnsmasq
echo 'address=/.test/127.0.0.1' >> /usr/local/etc/dnsmasq.conf

# 创建 DNS 解析器
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'

# 启动 dnsmasq
brew services start dnsmasq
```

### 2. Xdebug 调试配置

Xdebug 3.x 已预装在镜像中，配置位于 `config/php/php72.ini`。

#### 启用调试

在请求中添加参数：`XDEBUG_TRIGGER=1`

或使用浏览器扩展：
- [Xdebug Helper (Chrome)](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc)
- [Xdebug Helper (Firefox)](https://addons.mozilla.org/en-US/firefox/addon/xdebug-helper-for-firefox/)

#### PhpStorm 配置

1. Settings → Languages & Frameworks → PHP → Servers
   - Name: `laravel.test`
   - Host: `laravel.test`
   - Port: `80`
   - Debugger: `Xdebug`

2. Settings → Languages & Frameworks → PHP → Debug
   - Port: `9003` (Xdebug 3.x 默认端口)

参考视频：[PhpStorm Xdebug 配置](https://www.bilibili.com/video/BV1nV411b7T3)

### 3. 容器间服务访问

#### 方案一：使用容器名称（推荐）

在 `docker-compose.yml` 中已配置 `extra_hosts`，PHP 容器可以通过域名访问其他服务：

```yaml
extra_hosts:
  - "api.test:nginx"  # 使用 nginx 容器名，自动解析
```

#### 方案二：使用服务名称

在 PHP 代码中直接使用服务名：

```php
// 访问 MySQL
$host = 'mysql';  // 容器名
$port = 3306;

// 访问 Redis
$redis = new Redis();
$redis->connect('redis', 6379);  // 容器名
```

### 4. 辅助命令别名（可选）

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# Docker Compose 别名
alias dup='docker compose up -d'
alias ddown='docker compose down'
alias drestart='docker compose restart'
alias dlogs='docker compose logs -f'
alias dexec='docker compose exec'

# 快速进入 PHP 容器
alias dphp='docker compose exec php72 bash'
```

### 5. 故障排查

#### 服务无法启动

```bash
# 查看服务状态
docker compose ps

# 查看详细日志
docker compose logs [service_name]

# 检查端口占用
lsof -i :80
lsof -i :3306
```

#### 权限问题

```bash
# 修复数据目录权限
sudo chown -R $USER:$USER data/
sudo chmod -R 755 data/
```

#### 网络问题

```bash
# 重建网络
docker compose down
docker network prune
docker compose up -d
```

## 七、更新日志

### 2024 重构版本

- ✅ 更新到 Docker Compose 最新格式（移除 version）
- ✅ 优化 Dockerfile，使用最佳实践
- ✅ 改进网络配置，移除静态 IP 依赖
- ✅ 添加环境变量示例文件
- ✅ 更新服务版本到最新稳定版
- ✅ 优化卷挂载，使用缓存模式提升性能
- ✅ 改进文档，添加更多使用示例

## 八、许可证

MIT License

