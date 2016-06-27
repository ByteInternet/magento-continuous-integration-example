#!/bin/sh

# die when a command has a nonzero exit code
set -e 

# make sure the required vagrant plugins are installed
vagrant plugin list | grep vagrant-vbguest || vagrant plugin install vagrant-vbguest
vagrant plugin list | grep vagrant-hostmanager || vagrant plugin install vagrant-hostmanager

# if hypernode-vagrant directory exists
if test -d hypernode-vagrant; then
    cd hypernode-vagrant
    # Destroy lingering instance if there is one
    vagrant destroy -f
    cd ../

    # Remove previous Vagrant checkout if it exists
    rm -Rf hypernode-vagrant
fi

# create a new checkout of the hypernode-vagrant repo
git clone https://github.com/ByteInternet/hypernode-vagrant

# move into the hypernode-vagrant repository directory
cd hypernode-vagrant

# write our local.yml to the hypernode-vagrant directory
cat << EOF > local.yml
---
fs:
  type: virtualbox
  folders:
    magento1:
      host: data/web/public
      guest: "/data/web/public"
    nginx:
      host: data/web/nginx/
      guest: "/data/web/nginx/"
  disabled_folders:
    magento2:
      host: data/web/magento2
      guest: "/data/web/magento2"
hostmanager:
  extra-aliases:
  - my-custom-store-url1.local
  - my-custom-store-url2.local
magento:
  version: 1
php:
  version: 5.5
varnish:
  state: false
vagrant:
  box: hypernode_php5
  box_url: http://vagrant.hypernode.com/customer/php5/catalog.json
EOF

# make sure we have the last hypernode revision
vagrant box update || /bin/true  # don't fail if the box hasn't been added yet
# boot new vagrant instance
vagrant up
# register unique hostname of booted instance
BOX_IP=$(vagrant ssh-config | grep HostName | awk '{print$NF}')
echo "Registered ip: $BOX_IP"
echo "ansible_ssh_port: $(vagrant ssh-config | grep Port | awk '{print $NF}')" >> ../vars_test.yml

cd ../

# don't check ssh host key of vagrant box
export ANSIBLE_HOST_KEY_CHECKING=False

# apply deployment playbook
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_test.yml" --user=app -i "$BOX_IP," # mind the trailing comma

# run the provisioning scripts again
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_test.yml" --user=app -i "$BOX_IP," # mind the trailing comma

cd hypernode-vagrant
# Destroy test instance
vagrant destroy -f
cd ../
