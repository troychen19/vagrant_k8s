#!/usr/bin/env bash

# host config
hostnamectl set-hostname 'node2'
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
		
# SSH
#sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
#sudo sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
#systemctl restart sshd
	
# Install base software
yum -y update
yum install -y wget curl conntrack-tools vim net-tools telnet tcpdump bind-utils \
nc ntp kmod ceph-common dos2unix etcd yum-utils

sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum -y update
yum -y install docker-ce docker-ce-cli
yum -y install kubelet kubeadm kubectl
		
#Enable Firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=3000-5000/tcp
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd –-reload
modprobe br_netfilter

#Timezone
cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime
timedatectl set-timezone Asia/Taipei		

systemctl start ntpd
systemctl enable ntpd

# Start docker
systemctl enable docker
systemctl start docker

cat <<EOF > /etc/docker/daemon.json
{
"exec-opts":["native.cgroupdriver=systemd"]
}
EOF

systemctl restart docker

systemctl enable kubelet
systemctl start kubelet 

reboot

