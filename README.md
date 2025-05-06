# salt-module-initial-setup-for-remote-control

Automate SSH-loginto all minions, enable UFW on all minions, and enable apache with a new virtual host on minions starting with web.

### Linux installation
*Instructions for vagrant installation are at bottom under Vagrant setup*

**Minion:**
- download and run minion.sh file

**Master:**
- download and run master.sh file
- in current sudo user's home directory run:

```
sudo salt-key -A -y # for accepting all keys without prompt
git clone https://github.com/jaolim/salt-admin-setup.git
cd salt-admin-setup
bash master-module.sh
sudo salt '*' state.apply
```

## Contains:

**salt setup:**

master.sh: 

```sudo apt-get update
sudo apt-get install curl -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt-get update
sudo apt-get install salt-master -y
sudo apt-get install git -y
```
- ```bash master.sh``` to set up salt-master

slave.sh: 

```
sudo apt-get update
sudo apt-get install curl -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt-get update
sudo apt-get install salt-minion -y
echo "master: 192.168.2.10" | sudo tee -a /etc/salt/minion #update master IP
sudo systemctl restart salt-minion
```

- update master's IP unless using the same vagrant setup
- ```bash slave.sh``` to set up salt-minion

**Module setup:**

master-module.sh:

```
ssh-keygen -q -t rsa -N "" -f ../.ssh/id_rsa <<< y
sudo mkdir /srv/salt
sudo cp -a ./admin /srv/salt/admin
sudo cp -a ./web /srv/salt/web
sudo cp -a ../.ssh/id_rsa.pub /srv/salt/admin/id_rsa.pub
sudo cp -a ./top.sls /srv/salt/top.sls

```

- ```bash master-module.sh``` in master home directory to generate SSH-key and set up modules

**Modules**

/srv/salt/top.sls:

```
base:
  '*':
    - admin
  'web*':
    - web
```

- module configuration for minions based on minion name

**All minions**

/srv/salt/admin/init.sls:

```
admin:
  group.present:
    - gid: 1234

control:
  user.present:
    - fullname: Boss
    - shell: /bin/bash
    - password: '$6$FMzzQ..34PLTgqMd$FqXe3tmhA6VbNmgNW7dziCraT5BjyBVMnK8wYPquh9H9zcETWMYSZYU89BFut4QQomBQ6UDtP5nNvqhGElFdd.' # change to a password hash of your choice, to generate hash of 'your password' locally you can use: sudo salt-call --local shadow.gen_password 'your password'
    - home: /home/control
    - uid: 1234
    - gid: 1234
    - groups:
      - sudo
      - admin
      
ssh:
  service.running

sshkey:
  ssh_auth:
    - present
    - require:
      - user: control
    - user: control
    - source: salt://admin/id_rsa.pub

ufw:
  pkg.installed

ufw_service:
  service.running:
    - name: ufw

ufw enable:
  cmd.run:
    - unless: "ufw status | grep 'Status: active'"

ufw allow 22/tcp:
  cmd.run:
    - unless: "ufw status | grep '22/tcp'"
```

- makes user named *control* in *admin* and *sudo* groups exists
 - change the hashed password in *init.sls* to a password of your own
  - ```sudo salt-call --local shadow.gen_password 'your password'``` to generate password hash of 'your password' locally
- makes sure ssh-login is enabled with master's key
- ensures ufw is installed and enabled with 22 port open for tcp connections

**Web minions**

/srv/salt/web/init.sls:

```
apache2:
  pkg.installed

/home/control/public/html/default.com/index.html:
  file.managed:
    - makedirs: True
    - user: control
    - group: admin
    - source: salt://web/index.html

/etc/apache2/sites-available/default.com.conf:
  file.managed:
    - source: salt://web/default.com.conf

/etc/apache2/sites-enabled/default.com.conf:
  file.symlink:
    - target: ../sites-available/default.com.conf

apache2service:
  service.running:
    - name: apache2
    - watch:
      - file: /etc/apache2/sites-enabled/default.com.conf

a2dissite 000-default.conf && systemctl restart apache2:
  cmd.run:
    - onlyif: "ls /etc/apache2/sites-enabled | grep '000-default.conf'"

ufw allow 80/tcp:
  cmd.run:
    - unless: "ufw status | grep '80/tcp'"

ufw allow 443/tcp:
  cmd.run:
    - unless: "ufw status | grep '443/tcp'"
```

- makes sure apache is installed and running
- makes sure virtual host default.com is enabled
- makes sure apache default virtual host is diables
- ensures ports 80 and 443 are open for tcp connections

/srv/salt/web/default.com.conf:

```
<VirtualHost *:80>
  ServerName default.com
  ServerAlias www.default.com localhost http://localhost
  DocumentRoot /home/control/public/html/default.com
  <Directory /home/control/public/html/default.com>
    Require all granted
  </Directory>
</VirtualHost>
```

- source file for virtual host

/srv/salt/web/index.html:

```
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8"/>
		<title>Home</title>
	</head>
	<body>
		<h1>Hello web minion!</h1>
	</body>
</html>
```

- source file for website

## Vagrant setup

Make vagrantfile with following contents, make a folder called provision in that same folder, and copy slave.sh and master.sh files to that provision folder.

Vagrantfile:

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

- Uncomment *minion01* if you want two minions.

### Installation with vagrant setup

```
vagrant up
vagrant reload #Might not be needed, I had issues with salt-key request coming through without reloading
vagrant ssh master
sudo salt-key -A -y # for accepting all keys without prompt
git clone https://github.com/jaolim/salt-admin-setup.git
cd salt-admin-setup
bash master-module.sh
sudo salt '*' state.apply
```

### Purpose

The project was created for Haaga-Helia's Configuration Management Systems course [task h5 - mini project](https://terokarvinen.com/palvelinten-hallinta/#h5-miniprojekti).

Report of the creation process can be found [in Finnish at my course task report repo](https://github.com/jaolim/palvelinten-hallinta/blob/main/h5-miniprojekti.md)