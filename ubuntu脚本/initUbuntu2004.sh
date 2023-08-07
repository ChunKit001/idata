#!/bin/sh

## 更新apt源
config_file="/etc/apt/sources.list"
backup_format="/etc/apt/sources.list_bak_%Y%m%d_%H%M%S"
current_datetime=$(date +'%Y%m%d_%H%M%S')
backup_file=$(date +"$backup_format")
cp $config_file $backup_file
echo "已备份 $config_file 到 $backup_file"

cat > /etc/apt/sources.list << EOF
# 源地址https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse

# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
EOF

apt update
apt -y upgrade

## 升级linux内核
# 安装新的内核版本
sudo apt install -y linux-generic linux-headers-generic

# 查找当前正在使用的内核版本
current_kernel_version=$(uname -r)

# 查找已安装的内核版本列表
installed_kernel_versions=$(dpkg -l | grep 'linux-image' | awk '{print $2}')

# 删除不再需要的旧内核版本
for kernel_version in $installed_kernel_versions; do
    if [ "$kernel_version" != "$current_kernel_version" ]; then
        echo "删除内核版本: $kernel_version"
        sudo apt remove -y "$kernel_version"
    fi
done

# 清理已卸载的内核版本的相关文件
sudo apt autoremove -y
echo "内核升级和清理已完成"

## 安装常用软件
apt install -y openssh-server lrzsz vim

## 设置hostname
hostnamectl set-hostname sinmachine --static

## 修改pip源为国内 豆瓣
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host=pypi.tuna.tsinghua.edu.cn
EOF

