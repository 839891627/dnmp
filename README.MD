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

## 使用
- 项目配置 **redis**、**mysql** 时，填写 **容器名**，而不是 `127.0.0.1`
- laravel 项目执行 artisan 命令
> `docker-compose exec php71 bash` 进入 php71 容器 bash，然后切换到项目目录执行

## 快捷命令
- composer
- npm

# fish shell 中直接运行 php composer
```bash
function composer
    set p (pwd |xargs basename)
    set pp /var/www/$p
    docker exec -it -w $pp php-7.1 composer $argv
end
function php71
    set p (pwd |xargs basename)
    set pp /var/www/$p
    docker exec -it -w $pp php-7.1 php $argv
end
function php73
    set p (pwd |xargs basename)
    set pp /var/www/$p
    docker exec -it -w $pp php-7.3 php $argv
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
