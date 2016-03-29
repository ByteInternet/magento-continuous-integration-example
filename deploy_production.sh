#!/bin/sh

PRODUCTION_HOSTNAME='example.hypernode.io'

# die when a command has a nonzero exit code
set -e 

# apply deployment playbook with production settings
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_prod.yml" --user=app -i "$PRODUCTION_HOSTNAME," # mind the trailing comma

# test if the production Hypernode was succesfully provisioned
TEST_URL=$PRODUCTION_HOSTNAME nosetests testcase.py
