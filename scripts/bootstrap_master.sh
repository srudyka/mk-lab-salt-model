#!/usr/bin/env bash

readonly base_dir=/srv/salt/reclass
readonly ubuntu_release=xenial

echo "deb [arch=amd64] http://apt.tcpcloud.eu/nightly/ ${ubuntu_release} main security extra tcp tcp-salt" > /etc/apt/sources.list.d/tcpcloud.list
wget -O - http://apt.tcpcloud.eu/public.gpg | apt-key add -

apt-get clean
apt-get update

echo "Configuring salt master ..."
apt-get install -y salt-master reclass
apt-get install -y salt-formula-apache salt-formula-backupninja salt-formula-billometer salt-formula-ceilometer salt-formula-cinder salt-formula-collectd salt-formula-elasticsearch salt-formula-galera salt-formula-git salt-formula-glance salt-formula-glusterfs salt-formula-grafana salt-formula-graphite salt-formula-haproxy salt-formula-heat salt-formula-heka salt-formula-horizon salt-formula-iptables salt-formula-java salt-formula-kedb salt-formula-keepalived salt-formula-keystone salt-formula-kibana salt-formula-libvirt salt-formula-linux salt-formula-memcached salt-formula-mongodb salt-formula-mysql salt-formula-neutron salt-formula-nginx salt-formula-nodejs salt-formula-nova salt-formula-ntp salt-formula-opencontrail salt-formula-openssh salt-formula-openvstorage salt-formula-postgresql salt-formula-python salt-formula-rabbitmq salt-formula-reclass salt-formula-redis salt-formula-salt salt-formula-sensu salt-formula-statsd salt-formula-supervisor

cat > /etc/salt/master.d/master.conf <<EOF
file_roots:
  base:
  - /usr/share/salt-formulas/env
pillar_opts: False
open_mode: True
reclass: &reclass
  storage_type: yaml_fs
  inventory_base_uri: $base_dir
ext_pillar:
  - reclass: *reclass
master_tops:
  reclass: *reclass
EOF

[ ! -d /etc/reclass ] && mkdir /etc/reclass
cat > /etc/reclass/reclass-config.yml <<EOF
storage_type: yaml_fs
pretty_print: True
output: yaml
inventory_base_uri: $base_dir
EOF

apt-get install -y salt-minion
cat >> /etc/salt/minion.d/minion.conf <<EOF
master: 127.0.0.1
id: $(hostname -f)
EOF

mkdir -p $base_dir/classes/service

for i in /usr/share/salt-formulas/reclass/service/*; do
  ln -f -s $i $base_dir/classes/service/
done
