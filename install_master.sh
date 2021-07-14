#!/usr/bin/env bash

# host config
hostnamectl set-hostname 'master'
echo 'set host name resolution'
cat >> /etc/hosts <<EOF
192.168.56.101 master
192.168.56.102 node1
192.168.56.103 node2
192.168.56.105 repo
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
nc ntp kmod ceph-common dos2unix etcd yum-utils iptables

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
		
#Enable iptable
systemctl stop firewalld
systemctl disable firewalld
systemctl start iptables
systemctl enable iptables

cat <<EOF > /etc/sysconfig/iptables
#--- Master Node
-A INPUT -p tcp -m state --state NEW -m tcp --dport 6443 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 2379:2380 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10250:10252 -j ACCEPT
#--- Worker Node
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10250 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 3000:5000 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 30000:32767 -j ACCEPT
EOF
systemctl restart iptables

# enable br_netfilter
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables


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
"insecure-registries":[
    "192.168.56.105:8083",
    "repo:8083"],
"exec-opts":["native.cgroupdriver=systemd"]
}
EOF

systemctl restart docker

# Start k8s
systemctl enable kubelet
systemctl start kubelet 

kubeadm config images pull

