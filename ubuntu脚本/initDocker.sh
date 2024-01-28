#!/bin/sh

apt update
apt upgrade

#docker安装
wget -qO- https://get.docker.com/ | sh

cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn/",
    "https://hub-mirror.c.163.com",
    "https://registry.docker-cn.com",
    "https://reg-mirror.qiniu.com",
  ]
}
EOF

#非root用户赋予docker权限
groupadd docker
usermod -aG docker sin
newgrp docker
systemctl daemon-reload
systemctl restart docker

apt clean
sudo apt autoremove -y