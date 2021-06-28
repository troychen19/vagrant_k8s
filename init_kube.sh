#!/usr/bin/env bash

rm /vagrant/init_token
kubeadm init --apiserver-advertise-address=192.168.56.101 \
--pod-network-cidr=10.244.0.0/16 \
--service-cidr=10.96.0.0/12 >> init_token
		
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
		
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml