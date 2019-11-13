# 运行
```
docker-compose up -d
```

## 切换 php 版本
开启 `docker-compose.yml` 内 **php73** 部分，然后 `docker-compose up -d php73`, `nginx.conf` 内 `fastcgi_pass php73:9000;` 即可
