ssh-keygen -q -t rsa -N "" -f ../.ssh/id_rsa <<< y
sudo mkdir /srv/salt
sudo cp -a ./admin /srv/salt/admin
sudo cp -a ../.ssh/id_rsa.pub /srv/salt/admin/id_rsa.pub