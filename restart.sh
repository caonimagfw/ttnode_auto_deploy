#!/bin/sh

docker rm -f ttnode || echo 'remove ttnode container'

docker rmi -f registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest || echo 'remove tiptime/ttnode from ali'
docker rmi -f tiptime/ttnode:latest || echo 'remove tiptime/ttnode from dockerhub'

docker run --privileged -d \
  -v $1:/mnt/data/ttnode \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /proc:/host/proc:ro \
  --name ttnode \
  --hostname ttnode \
  --net=host \
  --restart=always \
  registry.cn-hangzhou.aliyuncs.com/tiptime/ttnode:latest
