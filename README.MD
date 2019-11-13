# 运行
```
docker-compose up -d
```

## 切换 php 版本
开启 `docker-compose.yml` 内 **php73** 部分，然后 `docker-compose up -d php73`, `nginx.conf` 内 `fastcgi_pass php73:9000;` 即可

## 使用
- laravel 项目执行 artisan 命令
> `docker-compose exec php71 bash` 进入 php71 容器 bash，然后切换到项目目录执行

## 其他
以下工具没有安装,在宿主机装好了（懒）
- composer
- npm
- ...