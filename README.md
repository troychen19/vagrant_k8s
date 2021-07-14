使用 vagrant + VirtualBox 建立 kubernetes 群集
* 作業系統版本： CenteOS 7.9
* OS Image 是使用 [chef/bento](https://github.com/chef/bento) 建立

---

# 環境說明
設定三台主機，每台主機個自執行安裝 script，master 在部分設定安裝完成後要重開機才能生效，因此使用了 vagrant reload
|  name  |       IP        |
| :----: | :-------------: |
| master | private: 192.168.153.101 <br/> public: 192.168.10.46 |
| node1 |  192.168.153.102|
| node2 | 192.168.153.103 |
| docker repository | 192.168.153.105 |

*在非本機執行時，需要加上 public_network 讓外部主機連線*
```ruby
master.vm.network "public_network", ip: "192.168.10.46", bridge: "eth0"
```

# 執行順序
1. 啟動 repo 並建立好 private repo
```
vagrant up repo
```
2. 啟動 vagrant
```bash
vagrant up
```
3. 在 master 的帳號加入 config 設定
```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
4. 查詢 join node token
```bash
cat .\init_token
```
5. 將 node2、node3 加入 master
```bash
kubeadm join 192.168.56.101:6443 --token <token> \
	--discovery-token-ca-cert-hash <hash> 
```
6. 檢查是否正確
```
kubectl get nodes
```
---

# Vagrant 檔案說明
|  檔名  |       說明        |
| :---- | :------------- |
| Vagrant | vagrant 啟動檔，包含了四台主機的設定 |
| install_maste.sh | 安裝設定 kubernete 環境 |
| init_kube.sh | 初始化 k8s |
| install_node1.sh <br/> install_node2.sh | 安裝設定 kubernete 環境 |

# docker 私有倉庫建立

* 在 nexus 建立 docker_host repository，設定 http prot 為 8083
* 修改 /etc/docker/daemon.json
```json
{
  "insecure-registries":["192.168.56.105:8083"],
  "exec-opts":["native.cgroupdriver=systemd"]
}
```
* 重新啟動 docker
* 登入
```
docker login -a admin -p admin 192.168.153.105:8083
```



