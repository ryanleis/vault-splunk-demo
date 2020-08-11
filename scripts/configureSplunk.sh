#!/usr/bin/env bash

SPLUNK_HOME=/opt/splunk
export PATH=$PATH:$SPLUNK_HOME/bin

# enable http event collector
splunk http-event-collector enable -uri https://localhost:8089 -auth admin:password

# add events index
splunk add index vault-audit \
    -homePath /opt/splunk/var/lib/splunk/vault-audit/db \
    -coldPath /opt/splunk/var/lib/splunk/vault-audit/colddb \
    -thawedPath /opt/splunk/var/lib/splunk/vault-audit/thaweddb \
    -datatype event \
    -auth admin:password

# add metcics index
splunk add index vault-metrics \
    -homePath /opt/splunk/var/lib/splunk/vault-metrics/db \
    -coldPath /opt/splunk/var/lib/splunk/vault-metrics/colddb \
    -thawedPath /opt/splunk/var/lib/splunk/vault-metrics/thaweddb \
    -datatype metric \
    -auth admin:password

# http event collector for audit log
splunk http-event-collector create vault-audit \
    -uri https://localhost:8089 \
    -description "Vault file audit device log" \
    -disabled 0 \
    -index vault-audit \
    -indexes vault-audit \
    -sourcetype hashicorp_vault_audit_log \
    -auth admin:password

# http event collector for vault metrics
splunk http-event-collector create vault-metrics \
    -uri https://localhost:8089 \
    -description "Vault telemetry metrics" \
    -disabled 0 \
    -index vault-metrics \
    -indexes vault-metrics \
    -sourcetype hashicorp_vault_telemetry \
    -auth admin:password

# disable ssl
splunk http-event-collector update \
    -enable-ssl 0 \
    -uri https://localhost:8089 \
    -auth admin:password

# grant admin access to indexes
cat > /opt/splunk/etc/system/local/authorize.conf << EOF
[role_admin]
srchMaxTime = 8640000
srchIndexesDefault = main;vault-audit;vault-metrics
srchIndexesAllowed = *;_*;vault-audit;vault-metrics
grantableRoles = admin
EOF

# output hec token for telegraf/td-agent
splunk http-event-collector list  -uri https://localhost:8089 -output json | jq -r '.[] | select(.name == "http://vault-metrics") | .token' > /vagrant/hec_token_metrics.txt
splunk http-event-collector list  -uri https://localhost:8089 -output json | jq -r '.[] | select(.name == "http://vault-audit") | .token' > /vagrant/hec_token_audit.txt

splunk restart

exit 0