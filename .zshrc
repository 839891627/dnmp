# 说明：此 alias 是为了能够在宿主机直接运行 php 命令。
fun php(){
    p=`pwd`
    # 查询当前所在目录名称，然后通过 -w 执行docker 命令，将工作目录切换到指定目录
    # 例如：当前在宿主机的 `~/php/laravel` 中执行 `php artisan xxx`，则 对应的是在容器中 `/var/www/laravel` 中执行
    # 如果不配置此项，每次执行脚本，都需要 先进入容器 `docker exec -it php72 bash`, 然后切换到 /var/www/laravel 再执行 php artisan xxx
    # 这里就是 bash 命令，截取当前所在目录名称 `~/php/laravel` 中的 laravel 这几个字
    i=$p[(I)php]
    if [ $i -gt 0 ]; then
        b=${p:t}
        docker exec -it -w /var/www/$b php72 php "$@"
    else
    # 此命令，就是在任意目录执行 php 命令
        docker exec -it  php72 php "$@"
    fi
}

# 快捷命令进入 php 容器
fun dp(){
    docker exec -it php72 bash
}

# 以下可以根据喜好自行调整
alias dup='docker-compose up'
alias composer='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php72 composer'
alias node='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php72 node'
alias npm='a=`pwd`;b=${a:t};docker exec -it -w /var/www/$b php72 npm'
alias dup='docker-compose up'
alias dps='docker-compose ps'
alias ddown='docker-compose down'
alias dr='docker-compose restart'
alias dc='docker-compose exec'


