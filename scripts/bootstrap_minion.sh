#!/bin/bash
echo "Preparing base OS"
which wget >/dev/null || (apt-get update; apt-get install -y wget)

cat > /etc/apt/sources.list <<EOF
deb [arch=amd64] http://apt.tcpcloud.eu/nightly/ trusty main
deb [arch=amd64] http://repo.saltstack.com/apt/ubuntu/14.04/amd64/2016.3 trusty main
EOF

wget -O - http://apt.tcpcloud.eu/public.gpg | apt-key add -

apt-get clean
apt-get update
apt-get install -y --force-yes salt-minion

cat > /etc/salt/minion <<EOF
id: $(hostname -f)
master: cfg01.mk20-lab-basic.local
EOF

rm -f /etc/salt/pki/minion/minion_master.pub
service salt-minion restart
echo "Showing node metadata..."
salt-call --no-color pillar.data
echo "Running complete state ..."
salt-call -l info state.sls linux,openssh,salt
