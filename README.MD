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



## 已知问题
- DNS 查询很慢