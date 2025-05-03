sudo apt-get install curl -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt-get update
sudo apt-get install salt-master -y
sudo apt-get install git -y
ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa <<< y
sudo mkdir /srv/salt
cp ~/.ssh/id_rsa.pub ~/salt-admin-setup/admin/id_rsa.pub
sudo cp -r -p ~/salt-admin-setup/admin /srv/salt/admin