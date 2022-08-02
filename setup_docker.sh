#!/bin/bash

config_dir="/etc/ttnode"
config_file="$config_dir/config.txt"

# 配置默认值
eth="eth0"
eth_dir="/sys/class/net"
eth_file=$eth_dir/$eth
memory=1g
cpus=1.5
cache_dir="/mnt/ttnode"
ttnode_count=1
name_prefix="ttnode-"
mac_vlan_subnet="172.16.6.0/24"
mac_vlan_name="macnet"

# ip forward
sysctl -w net.ipv4.ip_forward=1

echo $eth_file
if [ ! -e $config_file ] && [ -z $1 ]
then
    echo "没有配置文件，请输入参数部署 ----------------"
    echo " "
    exit 0
fi

if [ ! -z $1 ]
then
    echo "使用参数部署 ----------------"
    echo " "

    for i in "$@"
    do
    case $i in
        -e=*|--eth=*)
        eth="${i#*=}"
        ;;
        -edir=*|--eth_dir=*)
        eth_dir="${i#*=}"
        ;;
        -c=*|--cache_dir=*)
        cache_dir="${i#*=}"
        ;;
        -m=*|--memory=*)
        memory="${i#*=}"
        ;;
        -cpu=*|--cpus=*)
        cpus="${i#*=}"
        ;;
        -t=*|--ttnode_count=*)
        ttnode_count="${i#*=}"
        ;;
        --default)
        DEFAULT=YES
        ;;
        *)
        ;;
    esac
    done

    mkdir -p $config_dir
    "" > $config_file
#  第一行配置保存
    echo -e ",$eth, $mac_vlan_name, $mac_vlan_subnet" >> $config_file

    i=0
    while [ $i -lt $ttnode_count ]
    do
        let i++
#       随机 mac 地址
        mac_addr=$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(.\)\(..\)\(..\)\(..\)\(..\)\(..\).*$/\14:\2:\3:\4:\5:\6/g')

#       docker name hostname
        name="$name_prefix$i"
        host_name="$name_prefix$i"

#      ttnode 实例配置保存
        echo -e "$cache_dir, $name, $host_name, $memory, $cpus, $mac_vlan_name, $mac_addr" >> $config_file
    done

fi


#    --privileged=true \
startDocker(){
#      1
#    $cache_dir $name $host_name $memory $cpus $mac_vlan_name $mac_addr
    cache_dir=$1
    name=$2
    host_name=$3
    memory=$4
    cpus=$5
    mac_vlan_name=$6
    mac_addr=$7
    echo "mac addr ($mac_addr)"
    docker pull tiptime/ttnode
    docker run -d \
    -v $cache_dir:/mnt/data/ttnode \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name $name \
    --hostname $host_name \
    --net=$mac_vlan_name --mac-address $mac_addr \
    --restart=always \
    --memory=$memory \
    --cpus=$cpus \
    tiptime/ttnode
}

# 创建 maclvan 网络
createDockerMacvlan (){
    eth=$1
    name=$2
    subnet=$3
    docker inspect $name > /dev/null
#   该 macvlan 存在
    if [ $? -eq 0 ]
    then
        echo "macvlan $name 存在"
    else
        docker network create --subnet=$mac_vlan_subnet -o parent=$eth --driver=bridge $mac_vlan_name
        if [ ! $? -eq 0 ]
        then
          echo ""
          echo "无法创建 macvlan 请先删除此前 macvlan "
          echo "docker network ls             # 查看已有网络"
          echo "docker network rm 网络名        # 删除已有网络"
          exit 1
        fi
    fi
}

# 入口
if [ -e $config_file ]
then
    echo "使用配置文件 ----------------"
    n=0
    while read line; do
        let n++
#        echo $n
        array=(${line//,/ })
#        第一行配置
        if [ $n -eq 1 ]
        then
          eth=${array[0]}
          mac_vlan_name=${array[1]}
          mac_vlan_subnet=${array[2]}
          createDockerMacvlan $eth $mac_vlan_name $mac_vlan_name
        else
#          docker 实例配置
#          echo -e "$cache_dir, $name, $host_name, $memory, $cpus, $mac_vlan_name, $mac_addr" >> $config_file
            cache_dir=${array[0]}
            name=${array[1]}
            host_name=${array[2]}
            memory=${array[3]}
            cpus=${array[4]}
            mac_vlan_name=${array[5]}
            mac_addr=${array[6]}

           startDocker $cache_dir $name $host_name $memory $cpus $mac_vlan_name $mac_addr
        fi

    done < $config_file
fi









