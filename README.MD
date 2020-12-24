## 一、背景
docker 是啥、为啥使用它，咱们这里不加赘述。这里和大家分享下我搭建的 php 开发环境。  
 此仓库尽量遵循 **“精简原则”** 。尽量最小定制化，将定制工作交给使用者。 **授人以鱼不如授人以渔**，我希望通过简单的例子，给大家自行发挥的空间，毕竟每个人的需求有所差别。做大而全的东西，反而**臃肿看不懂**

## 二、亮点
好吧，自以为是的 **亮点**
- 简单
- **辅助脚本**
- 优化：脚本加速啥的
- 条理：构建脚本的分组等
- you say...

## 三、功能说明
### 1. 目录结构说明
```
.
├── .env  # 环境变量定义。在这里可以定义需要的 php/nginx/msyql 等版本以及端口号
├── Dockerfile  # php 镜像的构建脚本。里面主要安装了一些扩展以及前端需要的 nodejs、python
├── config
│   ├── nginx # nginx 配置文件夹。新项目的配置文件在这里添加 nginx 配置就可以了
│   ├── php # 这里有 php.ini。 里面我调整了 session.save_handler = redis 和 session.save_path = "tcp://redis:6379"。 表示用 redis(容器)来存储 session
│   └── redis.conf # redis 配置文件
├── data # 持久化数据库的目录
│   ├── composer
│   ├── mysql
│   └── redis
├── docker-compose.yml
├── logs  # 存放 nginx 日志
│   └── nginx
└── resources # 预先准备的资源
    ├── Python-3.8.0.tgz
    ├── mcrypt-1.0.3.tgz
    ├── mongodb-1.6.0.tgz
    ├── node-v12.13.0-linux-x64.tar.xz
    ├── redis-5.1.1.tgz
    ├── sources.list
    ├── swoole-src-4.4.12.zip
    └── xdebug-2.8.0.tgz
```
### 2. 集成的服务
- mysql
- php7.2/7.3
- nginx
- redis

## 三、使用
> 使用前强烈建议先将 docker-compose.yml、Dockerfile 熟悉一遍，很少的内容
 
1. 将此项目，克隆到你其他开发项目的平级目录

    ├── laravel # 例如有个 laravel 项目在这里  
    ├── dnmp # 那么，此项目你需要 clone 到这里

2. 启动/创建容器环境
然后切换到 dnmp 目录下，执行
    ```
    docker-compose up -d
    # 如果使用了 我下面给的 zshrc 的 alias，则是 dup -d 即可
    ```
3. 添加相应的 nginx 配置文件。参考 `config/nginx/conf.d/laravel.conf`
4. 如果有调整 nginx 配置，在 `dnmp` 目录下执行（重启 nginx 容器）  `docker-compose restart nginx`（使用了alias，则执行 `dr nginx`）
5. 可以项目访问了
   > 1. 配置宿主机 **hosts**，指定域名 `127.0.0.1 laravel.test`
   > 2. 项目中使用 mysql/redis 时，需要配置为 **容器名**。例如在 `laravel/env.php` 中
   > ```ini
   > REDIS_HOST=redis  # 填写redis, 运行时容器会自动解析的。因为 docker ps 查看，得知 redis 的容器名叫做 "redis"
   > # REDIS_HOST=127.0.0.1 # 而不是填写 ip
   > REDIS_PASSWORD=null
   > REDIS_PORT=6379
   > DB_CONNECTION=mysql
   > DB_HOST=mysql  # 同理，填写 mysql
   > #DB_HOST=127.0.0.1
   > DB_PORT=3306
   > DB_DATABASE=homestead
   > DB_USERNAME=homestead
   > DB_PASSWORD=secret
   > ```
   > 3. [可选项]这样用每个项目都得配置 host，比较麻烦，通过 **dnsmasq** 可以达到一劳永逸的目录。可以参照下面的附录


### 四、其他功能
1. 切换 php 版本
开启 `docker-compose.yml` 内 **php73** 部分，然后 `docker-compose up -d php73`, `nginx.conf` 内 `fastcgi_pass php73:9000;` 即可

2. 安装扩展
- `docker-php-ext-install -h` 查看可以安装的扩展
- `docker-php-ext-enable -h` 启用扩展
    > 如果需要的扩展没有的话，则自行通过 源码包安装。这里不做说明了

3. **执行 `php、composer` 等脚本**
    需要进入容器内进行 `docker exec -it php72 bash`，然后切换到相应的项目中执行
    > **php72** 是容器名称,在 docker-compose.yml 中 `container_name: php72` 中定义的
    > 使用 alias 的话，则直接可以在宿主机项目下运行命令，无需进入容器

### 五、附录
#### 辅助命令
请参考 `.zshrc`、`.fish` 配置。复制到你对应的配置中
#### 统一设置 **.test** 域名到本地
    > mac 下。linux 请自行尝试
1.  `brew install dnsmasq`
2. `/usr/local/etc/dnsmasq.conf` 里面配置 ` address=/.test/127.0.0.1`
3. Create a dns resolver：
    ```bash 
       sudo mkdir -v /etc/resolver
       sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
    ```
   
#### xdeug 使用
    > 安装的是 3.x 版本。端口号默认是 **9003**  
    > phpstorm 配置可以参照我这里视频：https://www.bilibili.com/video/BV1nV411b7T3?pop_share=1
    > `config/php/php72.ini`  
    > 配置中我已经配置好了，开启了 debug 和 profile(如果不需要，直接删除就行了)
GET/POST/COOKIE 添加参数 'XDEBUG_TRIGGER=任意值'

#### 关于容器内 A 项目 curl 访问 B 项目不同的解决
**1. 方案一**
  > 目前通过在 **php容器内**，修改 /etc/hosts 解决
  >
  > ```bash
  > docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx # 首先在宿主机中获取 nginx 容器 ip
  > docker exec -it php bash # 进入php容器
  > echo '第一步中返回的ip domain.test' >> /etc/hosts 
  > ```
**1. 方案二**
见 docker-compose.yml 
    ```apacheconf
        extra_hosts:
          - laravel.test:172.20.128.2 # 此 ip 是nginx容器ip，已经被设置为固定。这样不会因为每次重启，ip 变化的问题
    ```

