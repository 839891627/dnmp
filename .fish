# 我目录使用的是 zsh。fish的配置之前使用过，可以参考调整下就可以使用了

```bash
    function composer
        set p (pwd)
        # 这个35，是我自己宿主机的地址，即 /Users/caojinliang/Develop/Docker/ 共35个字符，换成你自己的
        set pp (string sub $p -s 35)
        set ppp /var/www/$pp
        docker exec -it -w $ppp php72 composer $argv
    end
    function php
        set p (pwd)
        set pp (string sub $p -s 35)
        set ppp /var/www/$pp
        docker exec -it -w $ppp php72 php $argv
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
