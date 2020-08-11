#!/usr/bin/env bash

VAULT_TOKEN=`cat /vagrant/primary-root-token.txt`
echo "VAULT Root Token is " $VAULT_TOKEN

# enable audit device
VAULT_TOKEN=$VAULT_TOKEN vault audit enable file file_path=/var/log/vault/vault-audit.log
