# 运行
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
> `docker-compose exec php71 bash` 进入 php71 容器 bash，然后切换到项目目录执行

## 快捷命令
- composer
- npm

# fish shell 中直接运行容器内命令
- **composer** php71容器
- **php** php71容器
- **dc 容器名称 命令** 万能脚本
    > - `dc php71 node -v` 
    > - `dc php73 node -v` 
    > - `dc nginx bash` 进入 nginx 容器 
- **dup [容器名]** 启动[指定]容器
- **dr [容器名]** 重启[指定]容器
- **dps** 查看进程
- **ddown** 关闭

```bash
    function composer
        set p (pwd)
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
- DNS 查询很慢
1.  `brew install dnsmasq`
2. `/usr/local/etc/dnsmasq.conf` 里面配置 ` conf-file=/etc/dnsmasq.conf`
3. 然后 `/etc/dnsmasq.conf` 文件内容
 ```
address=/.test/127.0.0.1
listen-address=127.0.0.1
```

- 容器内 node/npm 相关错误
需要进入容器
```bash
apt-get update && apt-get install python2.7
```
然后再执行相关命令
