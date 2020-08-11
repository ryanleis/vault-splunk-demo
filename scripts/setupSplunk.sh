#!/usr/bin/env bash

SPLUNK_HOME=/opt/splunk
export PATH=$PATH:$SPLUNK_HOME/bin

echo "Installing Splunk enterprise version ..."
cp /vagrant/ent/splunk*.tgz ./splunk.tgz
tar xvzf splunk.tgz -C /opt
rm -f splunk.tgz
echo "Installing Splunk enterprise complete"

# start splunk with admin/password set
echo "Start Splunk enterprise ..."
splunk start --accept-license --answer-yes --no-prompt --seed-passwd "password"
ps -ef | grep -v grep | grep splunk
echo "Start Splunk enterprise complete"

# add Vault splunk app
echo "Add Vault Splunk App ..."
cp /vagrant/ent/hashicorp-vault-app-for-splunk*.tgz ./hc_vault_splunk.tgz
splunk install app hc_vault_splunk.tgz -auth admin:password
rm -f hc_vault_splunk.tgz
echo "Add Vault Splunk App complete"

exit 0
