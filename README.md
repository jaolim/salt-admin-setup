# salt-module-initial-setup-for-remote-control

## Vagrant setup

If using vagrant to set up the environment move slave.sh and master.sh to *provision* folder that is in the same directory as vagrantfile.
Uncomment *minion01* if you want two minions.

**Vagrantfile:**

```
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"


  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.2.10"
	master.vm.provision "shell", path: "provision/master.sh"
  end

  config.vm.define "webminion01" do |webminion01|
    webminion01.vm.hostname = "webminion01"
    webminion01.vm.network "private_network", ip: "192.168.2.11"
	webminion01.vm.provision "shell", path: "provision/slave.sh"
  end
  
#  config.vm.define "minion01" do |minion01|
#    minion01.vm.hostname = "minion01"
#    minion01.vm.network "private_network", ip: "192.168.2.12"
#    minion01.vm.provision "shell", path: "provision/slave.sh"
#  end
  
end
```