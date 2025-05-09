sudo apt-get update
sudo apt-get install curl -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt-get update
sudo apt-get install salt-minion -y
echo "master: 192.168.2.10" | sudo tee -a /etc/salt/minion #update master IP
echo "tcp_keepalive: True" | sudo tee -a /etc/salt/minion #workaround for lost connection on ufw enable
echo "tcp_keepalive_idle: 10" | sudo tee -a /etc/salt/minion #workaround for lost connection on ufw enable
sudo systemctl restart salt-minion