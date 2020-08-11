#!/usr/bin/env bash

SPLUNK_IP=192.168.200.10
SPLUNK_HEC_AUDIT=`cat /vagrant/hec_token_audit.txt`
SPLUNK_HEC_METRICS=`cat /vagrant/hec_token_metrics.txt`

# Add influlx repo as a source list
cat <<EOF | tee /etc/apt/sources.list.d/influxdata.list
deb https://repos.influxdata.com/ubuntu bionic stable
EOF

#Import API key
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -

# install telegraf
apt-get update
apt-get -y install telegraf

# configure telegraf
cat > /etc/telegraf/telegraf.conf <<EOF

[global_tags]
  index="vault-metrics"
  datacenter = "dc1"
  role       = "vault-server"
  cluster    = "vtl"

[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = false

[[inputs.statsd]]
  protocol = "udp"
  service_address = ":8125"
  metric_separator = "."
  datadog_extensions = true

[[outputs.http]]
  url = "http://$SPLUNK_IP:8088/services/collector"
  data_format="splunkmetric"
  splunkmetric_hec_routing=true
  [outputs.http.headers]
    Content-Type = "application/json"
    Authorization = "Splunk $SPLUNK_HEC_METRICS"

[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false

[[inputs.mem]]

[[inputs.net]]

[[inputs.swap]]

[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

[[inputs.diskio]]
  # devices = ["sda", "sdb"]
  # skip_serial_number = false

[[inputs.kernel]]
  # No configuration required

[[inputs.linux_sysctl_fs]]
  # No configuration required

[[inputs.net]]
  # Specify an interface or all
  # interfaces = ["enp0s*"]

[[inputs.netstat]]
  # No configuration required

[[inputs.processes]]
  # No configuration required

[[inputs.procstat]]
 pattern = "(vault)"

[[inputs.system]]

EOF

systemctl restart telegraf


# Install & configure fluentd (td-agent)

curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-bionic-td-agent4.sh | sh

# configure td-agent
cat > /etc/td-agent/td-agent.conf <<EOF
<match td.*.*>
  @type tdlog
  @id output_td
  apikey YOUR_API_KEY

  auto_create_table
  <buffer>
    @type file
    path /var/log/td-agent/buffer/td
  </buffer>

  <secondary>
    @type file
    path /var/log/td-agent/failed_records
  </secondary>
</match>

## match tag=debug.** and dump to console
<match debug.**>
  @type stdout
  @id output_stdout
</match>

<source>
  @type forward
  @id input_forward
</source>

<source>
  @type http
  @id input_http
  port 8888
</source>

## live debugging agent
<source>
  @type debug_agent
  @id input_debug_agent
  bind 127.0.0.1
  port 24230
</source>

<source>
  @type tail
  path /var/log/vault/vault-audit.log
  pos_file /var/log/vault/vault-audit-log.pos
  <parse>
    @type json
    time_format %iso8601
  </parse>
  tag vault-audit
</source>

<match vault-audit.**>
  @type splunk_hec
  host $SPLUNK_IP
  port 8088
  token $SPLUNK_HEC_AUDIT
</match>

EOF

/usr/sbin/td-agent-gem install fluent-plugin-splunk-enterprise

systemctl restart td-agent

exit 0