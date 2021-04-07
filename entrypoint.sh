#!/bin/sh

set -eax

ip="${SN_PUBLIC_IP:-$(hostname -i | awk '{print $1}')}"

node_dir="${HOME}/.safe/node"
mkdir --parents "${node_dir}"

# Genesis node.
sn_node --skip-igd --first=0.0.0.0:12000 --root-dir "${node_dir}/12000" &

# Regular nodes connecting to genesis.
for port in $(seq 12001 12011); do
    sleep 1
    sn_node --skip-igd --local-addr=0.0.0.0:$port --public-addr=$ip:$port --hard-coded-contacts="[\"127.0.0.1:12000\"]" --root-dir "${node_dir}/$port" &
done

# Wait for initialisation.
sleep 12

# Launch authenticator.
sn_authd start --fg &

# Wait for background processes.
wait
