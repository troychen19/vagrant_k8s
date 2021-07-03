使用 vagrant + VirtualBox 建立 kubernetes 群集
作業系統版本： CenteOS 7.9
OS Image 是使用 [chef/bento](https://github.com/chef/bento) 建立

---

# 環境說明

設定三台主機，每台主機個自執行安裝 script，master 在部分設定安裝完成後要重開機才能生效，因此使用了 vagrant reload
|  name  |       IP        |
| :----: | :-------------: |
| master | private: 192.168.153.101 <br/> public: 192.168.10.46 |
| node1 |  192.168.153.102|
| node2 | 192.168.153.103 |
| docker repository | 192.168.153.105 |

# 執行

```
vagrant up
```





