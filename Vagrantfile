VAGRANT_BOX = "ubuntu/jammy64"
VAGRANT_BOX_VERSION = "20241002.0.0"
VAGRANT_PROVIDER = "virtualbox"

VM_MEMORY = 1024
VM_CPUS  = 1

SERVER_IP = "192.168.56.110"
WORKER_IP = "192.168.56.111"

Vagrant.configure("2") do |config|
  config.vm.box = VAGRANT_BOX
  config.vm.box_version = VAGRANT_BOX_VERSION
  
  config.vm.provider VAGRANT_PROVIDER do |vb|
    vb.memory = VM_MEMORY
    vb.cpus = VM_CPUS
  end

  config.vm.define "anloiseaS" do |s|
    s.vm.hostname = "anloiseaS"
    s.vm.network "private_network", ip: SERVER_IP
  end

  config.vm.define "anloiseaSW" do |ws|
    ws.vm.hostname = "anloiseaSW"
    ws.vm.network "private_network", ip: WORKER_IP
  end
end
