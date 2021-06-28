
Vagrant.configure("2") do |config|

  #config.vm.define "repo" do |repo|
  #	repo.vm.box = "centos-7.9"
  #	repo.vm.box_check_update = false
  #	repo.vm.provider "virtualbox" do |vb|
  #		vb.gui = false
  #		vb.name = "docker_repo"

  #		vb.memory = "1024"
  #		vb.cpus = 1
  #	end
	
	#repo.vm.network "private_network", ip: "192.168.56.105"
	#repo.vm.provision "shell", path: "install_docker.sh"
  #end
  
  config.vm.define "master" do |master|
	master.vm.box = "centos-7.9"
	master.vm.box_check_update = false
	master.vbguest.auto_update = false
	master.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.name = "k8s_master"

		vb.memory = "2048"
		vb.cpus = 2
	end

	master.vm.network "private_network", ip: "192.168.56.101"
	master.vm.provision "shell", path: "install_master.sh"
	config.vm.provision :reload
	master.vm.provision "shell", path: "init_kube.sh"
  end
  
  config.vm.define "node1" do |node1|
  	node1.vm.box = "centos-7.9"
	node1.vm.box_check_update = false
	node1.vbguest.auto_update = false
	node1.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.name = "k8s_node1"

		vb.memory = "1024"
		vb.cpus = 1
	end
	
	node1.vm.network "private_network", ip: "192.168.56.102"
	node1.vm.provision "shell", path: "install_node1.sh"

  end
  
  config.vm.define "node2" do |node2|
  	node2.vm.box = "centos-7.9"
	node2.vm.box_check_update = false
	node2.vbguest.auto_update = false
	node2.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.name = "k8s_node2"

		vb.memory = "1024"
		vb.cpus = 1
	end
	
	node2.vm.network "private_network", ip: "192.168.56.103"
	node2.vm.provision "shell", path: "install_node2.sh"
  end
    
end
