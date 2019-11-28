## 集成的服务
- mysql
- php7.1/7.3
- nginx
- redis

## 目录结构说明
```
├── Dockerfile # php镜像的构建脚本
├── README.MD
├── config    # 几个服务的配置文件目录
│   ├── nginx
│   └── php
├── data        # 数据持久化目录
│   ├── composer # 会用到缓存，所以持久化
│   ├── mysql
│   └── redis
├── docker-compose.yml
├── logs       # 目录只存放了 nginx
│   └── nginx
└── resources  # 预先准备的资源。 容器内 pecl/apt 安装下载太慢了，所以预准备
    ├── Python-3.8.0.tgz
    ├── node-v12.13.0-linux-x64.tar.xz
    ├── redis-5.1.1.tgz
    ├── sources.list
    ├── swoole-src-4.4.12.zip
    └── xdebug-2.8.0.tgz

```
## 运行
```
docker-compose up -d
```

## 重建某个容器
```bash
docker-compose down
docker-compose build php71
```
## 切换 php 版本
- 开启 `docker-compose.yml` 内 **php73** 部分，然后 `docker-compose up -d php73`, `nginx.conf` 内 `fastcgi_pass php73:9000;` 即可
- 需要配置 `hosts`

## resources
node/python等，本可以 apt-get 去直接安装，但是考虑到容器内每次要联网下载，所以直接用资源编译安装

## 使用
- 项目配置 **redis**、**mysql** 时，填写 **容器名**，而不是 `127.0.0.1`
- laravel 项目执行 artisan 命令
    > php artisan xxx
- `php71.ini` 配置了 `session.save_path = "tcp://redis:6379"` ,即使用 **redis** 容器来存放 session

## 快捷命令
- composer
- npm

# fish shell 中直接运行容器内命令
- **composer** 
    > php71容器
- **php** 
    > php71容器
- **dc 容器名称 命令** 
    > 万能脚本
    > - `dc php71 node -v` 
    > - `dc php73 node -v` 
    > - `dc nginx bash` 进入 nginx 容器 
- **dup [容器名]** 
    > 启动 [指定] 容器
- **dr [容器名]** 
    > 重启 [指定] 容器
- **dps** 
    > 查看进程
- **ddown** 
    > 关闭

```bash
    function composer
        set p (pwd)
        # 这个35，是我自己宿主机的地址，即 /Users/caojinliang/Develop/Docker/ 共35个字符，换成你自己的
        set pp (string sub $p -s 35) 
        set ppp /var/www/$pp
        docker exec -it -w $ppp php71 composer $argv
    end
    function php
        set p (pwd)
        set pp (string sub $p -s 35)
        set ppp /var/www/$pp
        docker exec -it -w $ppp php71 php $argv
    end
    function dc
        set p (pwd)
        set pp (string sub $p -s 35)
        set ppp /var/www/$pp
        docker exec -it -w $ppp $argv
    end
    function dup
        docker-compose up -d $argv
    end
    function dps
        docker-compose ps
    end
    function ddown
        docker-compose down
    end
    function dr
        docker-compose restart $argv
    end
```


## 已知问题
- [x] DNS 查询很慢
    1.  `brew install dnsmasq`
    2. `/usr/local/etc/dnsmasq.conf` 里面配置 ` conf-file=/etc/dnsmasq.conf`
    3. 然后 `/etc/dnsmasq.conf` 文件内容
        > 配置了这个，新项目就不需要添加 hosts 了
         ```
            address=/.test/127.0.0.1
            listen-address=127.0.0.1
        ```
