# Vault Splunk Intergration demo
Spin up Vault single node VM integrated with Splunk Enterprise that comes with Vault splunk app installed. This also installs Telegraf and Fluentd(td-agent) and configure to capture Vault metrics as well as events from audit logs, pushed to Splunk HTTP event collector interface for it to present them on a pre-built dashboard!

## Prerequisites
Place followings under `ent` directory

* Vault Enterprise binary
* Vault Enterprise license (store in license.txt)
* [Splunk Enterprise binary](https://www.splunk.com/en_us/download/splunk-enterprise.html) (Splunk account needs to be created to download free trial)
* [Vault Splunk App](https://splunkbase.splunk.com/app/5093/)

    * You must have appropriate Vault Enterprise license contracted to download this app

## Usage
Once you have all files downloaded and placed under `ent` directory, simply `vagrant up` in the root directory of this module.

#### Vault Web UI
http://192.168.100.10:8200 (user:admin pw:password)

#### Splunk Enterprise Web UI
http://192.168.200.10:8000 (root token is stored in /vagrant/primary-root-token.txt)

## Reference

* https://www.hashicorp.com/blog/splunk-app-for-monitoring-hashicorp-vault/

* https://learn.hashicorp.com/tutorials/vault/monitor-telemetry-audit-splunk

