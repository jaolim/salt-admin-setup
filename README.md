# salt-module-initial-setup-for-remote-control

## Vagrant setup

If using vagrant to set up the environment move slave.sh and master.sh to *provision* folder that is in the same directory as vagrantfile.

**Vagrantfile:**

```
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"


  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.2.10"
	master.vm.provision "shell", path: "provision/master.sh"
  end

  config.vm.define "slave001" do |slave001|
    slave001.vm.hostname = "slave001"
    slave001.vm.network "private_network", ip: "192.168.2.11"
	slave001.vm.provision "shell", path: "provision/slave.sh"
  end
  
end
```