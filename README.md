# ttnode 脚本

一、依赖
```shell
# 部署脚本会自动安装, 保证 apt update 可以正常使用即可
tar wget ca-certificates  qrencode  tar 
```

二、 部署脚本
1. debian ubuntu
参数 -c= ttnode缓存目录
```shell
sudo sh -c "$(wget https://gitee.com/shenzhen-sweet-sugar/ttnode-auto-deploy/raw/master/setup.sh -O -) -c=/mnt/data/ttnode"
 ```

三、查看日志二维码
```shell
sudo tail -f /usr/node/nohup.out
```
四、浏览器查看
```
http://ip:1024
```

## docker ttnode 
一、详细

> [dockerhub 地址](https://hub.docker.com/r/tiptime/ttnode)

二、docker ttnode  host 模式例子

```shell
sudo docker run -d \
  -v /mnt/host/dir:/mnt/data/ttnode \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name ttnode \
  --hostname ttnode \
  --net=host \
  --restart=always \
  --memory=2g \
  --cpus=1.5 \
  tiptime/ttnode:latest
```

