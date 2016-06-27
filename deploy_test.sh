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
# make sure we have the last hypernode revision
vagrant box update || /bin/true  # don't fail if the box hasn't been added yet
# boot new vagrant instance
vagrant up
# register unique hostname of booted instance
BOX_IP=$(vagrant ssh -- ip route | awk 'END{print $NF}')
echo "Registered ip: $BOX_IP"
cd ../

# don't check ssh host key of vagrant box
export ANSIBLE_HOST_KEY_CHECKING=False

# apply deployment playbook
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_test.yml" --user=app -i "$BOX_IP," # mind the trailing comma

# test if new node was successfully provisioned
TEST_URL=$BOX_IP nosetests testcase.py

# run the provisioning scripts again
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_test.yml" --user=app -i "$BOX_IP," # mind the trailing comma

cd hypernode-vagrant
# Destroy test instance
vagrant destroy -f
cd ../
