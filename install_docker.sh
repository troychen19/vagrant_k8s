#!/usr/bin/env bash

# host config
hostnamectl set-hostname 'nexus3'
echo 'set host name resolution'
cat >> /etc/hosts <<EOF
192.168.56.101 master
192.168.56.102 node1
192.168.56.103 node2
EOF
				
# disable selinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# ip v4 forward
cat >> /etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl --system
		
# disable swap
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# Install Docker
sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo

yum -y update
yum -y install docker-ce docker-ce-cli

#Timezone
cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime
timedatectl set-timezone Asia/Taipei		

systemctl start ntpd
systemctl enable ntpd

# Start docker
systemctl enable docker
systemctl start docker

mkdir /vagrant/nexus-data && chown -R 200 /vagrant/nexus-data
docker run -d -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 8084:8084 -p 8085:8085\
    --name nexus -v /vagrant/nexus-data:/nexus-data sonatype/nexus3



