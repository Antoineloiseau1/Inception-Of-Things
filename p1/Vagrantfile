VAGRANT_BOX = "ubuntu/jammy64"
VAGRANT_PROVIDER = "virtualbox"

#VM_MEMORY = 2048
#VM_CPUS  = 2

SERVER_IP = "192.168.56.110"
WORKER_IP = "192.168.56.111"

Vagrant.configure("2") do |config|
  config.vm.box = VAGRANT_BOX

  config.vm.define "anloiseaS" do |s|
    s.vm.hostname = "anloiseaS"
    s.vm.network "private_network", ip: SERVER_IP

    s.vm.provider VAGRANT_PROVIDER do |vb|
      vb.memory = 2048
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--name", "anloiseaS"]
    end

    s.vm.provision "shell", path: "scripts/install_k3s_server.sh"
  end

  config.vm.define "anloiseaSW" do |ws|
    ws.vm.hostname = "anloiseaSW"
    ws.vm.network "private_network", ip: WORKER_IP
    
    ws.vm.provider VAGRANT_PROVIDER do |vb|
      vb.memory = 512
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--name", "anloiseaSW"]
    end

    ws.vm.provision "shell", path: "scripts/install_k3s_agent.sh"
  end
end
