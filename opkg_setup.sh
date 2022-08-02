opkg update
opkg install wget ca-certificates qrencode
opkg upgrade tar

manager_x86="ttnode-manager-x86"
manager_arm32="ttnode-manager-arm32"
manager_arm64="ttnode-manager-arm64"
arm32_url="https://gitee.com/jimyfar/ttnode_auto_deploy/attach_files/923467/download/ttnode-manager-arm32.tar.gz"
arm64_url="https://gitee.com/jimyfar/ttnode_auto_deploy/attach_files/923472/download/ttnode-manager-arm64.tar.gz"
x86_url="https://gitee.com/jimyfar/ttnode_auto_deploy/attach_files/923473/download/ttnode-manager-x86.tar.gz"

manager=manager_arm32

platform=$(uname -a)
case $platform in
    *x86*)
        url=$x86_url
        manager=$manager_x86
        ;;
    *amd64*)
        url=$x86_url
        manager=$manager_x86
        ;;
    *armv8*)
        url=$arm64_url
        manager=$manager_arm64
        ;;
    *arm64*)
        url=$arm64_url
        manager=$manager_arm64
        ;;
    *aarch64*)
        url=$arm64_url
        manager=$manager_arm64
        ;;
    *)
        url=$arm32_url
        manager=$manager_arm32
esac

echo $url
tar_manager="$manager.tar.gz"
mkdir -p /opt/app
mkdir -p /mnt/data/ttnode
rm -rf /opt/app/ttnode-manager
rm -rf /opt/app/$tar_manager

cd /opt/app

wget $url
tar -xvf $tar_manager

mv $manager ttnode-manager

cd /opt/app/ttnode-manager
chmod +x ttnode_manager
./ttnode_manager
