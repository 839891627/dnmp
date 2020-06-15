## 集成的服务
- mysql
- php7.1/7.3
- nginx
- redis

## 目录结构说明
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
## 使用
> 将此项目，克隆到你其他开发项目的平级目录

启动/创建容器环境
    ```
    docker-compose up -d
    ```
### 切换 php 版本
开启 `docker-compose.yml` 内 **php73** 部分，然后 `docker-compose up -d php73`, `nginx.conf` 内 `fastcgi_pass php73:9000;` 即可

#### 安装扩展
- `docker-php-ext-install -h` 查看可以安装的扩展
- `docker-php-ext-enable -h` 启用扩展

### 配置新开发项目

1. 将项目放在同级目录
2. 添加 nginx 配置文件,例如：`config/nginx/conf.d/laravel.conf`
    ```nginx
       server_name laravel.test;
       root        /var/www/项目名称/public或其他入口目录; 
    ```
3. 配置宿主机 **hosts**，指定域名 `127.0.0.1 laravel.test`  
   
    > [可选项]这样用每个项目都得配置，比较麻烦，所以有以下方式快捷配置
4. 项目中使用 mysql/redis 时，需要配置为 **容器名**。例如在 `laravel/env.php` 中
    ```ini
    REDIS_HOST=redis  # 填写redis, 运行时容器会自动解析的。因为 docker ps 查看，得知 redis 的容器名叫做 "redis"
    # REDIS_HOST=127.0.0.1 # 而不是填写 ip
    REDIS_PASSWORD=null
    REDIS_PORT=6379

    DB_CONNECTION=mysql
    DB_HOST=mysql  # 同理，填写 mysql
    #DB_HOST=127.0.0.1
    DB_PORT=3306
    DB_DATABASE=homestead
    DB_USERNAME=homestead
    DB_PASSWORD=secret
    ```
5. 执行 `php、composer` 等脚本  
需要进入容器内进行 `docker exec -it php71 bash`，然后切换到相应的项目中执行 **php71** 是容器名称,在 docker-compose.yml 中 `container_name: php71` 中定义的
   
    > 如果觉得麻烦，继续往下看，设置 shell 的 alias

### 统一设置 **.test** 域名到本地

1.  `brew install dnsmasq`
2. `/usr/local/etc/dnsmasq.conf` 里面配置 ` address=/.test/127.0.0.1`
3. Create a dns resolver：
    ```bash 
       sudo mkdir -v /etc/resolver
       sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
    ```

## 快捷命令

- composer
- npm
### iterm shell 中直接运行容器内命令
`vi ~/.zshrc`
```bash
fun php(){
    p=`pwd`
    # 我的宿主机是目录名是： docker
    i=$p[(I)docker] 
    if [ $i -gt 0 ]; then
        b=${p:t}
        docker exec -it -w /var/www/$b php71 php "$@"
    else
        docker exec -it  php71 php "$@"
    fi
}
fun php73(){
    p=`pwd`
    i=$p[(I)docker]
    if [ $i -gt 0 ]; then
        b=${p:t}
        docker exec -it -w /var/www/$b php73 php "$@"
    else
        docker exec -it  php73 php "$@"
    fi
}
alias dup='docker-compose up'
#alias php='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php71 php'
alias composer='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php71 composer'
alias node='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php71 node'
alias npm='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php71 npm'
#alias php73='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php73 php'
alias dup='docker-compose up'
alias dr='docker-compose r'
alias dps='docker-compose ps'
alias ddown='docker-compose down'
alias dr='docker-compose restart'
alias dc='docker-compose exec'
```

### fish shell 中直接运行容器内命令

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

> 以下脚本大致意思是：
> 你在`当前项目下运行`，执行后，会直接帮你在 容器内的 `当前项目` 下执行对应命令
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

### Q&A

- 本地项目，通过域名访问不解析问题

  > 目前通过在 **php容器内**，修改 /etc/hosts 解决
  >
  > ```bash
  > docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx # 首先在宿主机中获取 nginx 容器 ip
  > docker exec -it php bash # 进入php容器
  > echo '第一步中返回的ip domain.test' >> /etc/hosts 
  > ```

- 如果固定容器IP

  https://github.com/yeszao/dnmp/issues/91