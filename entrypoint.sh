#!/bin/sh

set -eax

# Use a specified IP (e.g. 127.0.0.1), or fall back to first address we find (e.g. 172.17.0.2).
ip="${SN_PUBLIC_IP:-$(hostname -i | awk '{print $1}')}"

node_dir="${HOME}/.safe/node"
mkdir --parents "${node_dir}"

# Genesis node.
sn_node -vv --skip-igd --clear-data \
    --first=0.0.0.0:12000 --public-addr=$ip:12000 \
    --log-dir "${node_dir}/12000" --root-dir "${node_dir}/12000" &

# Regular nodes connecting to genesis.
for port in $(seq 12001 12011); do
    sleep 1
    sn_node -vv --skip-igd --clear-data \
        --local-addr=0.0.0.0:$port --public-addr=$ip:$port --hard-coded-contacts="[\"$ip:12000\"]" \
        --log-dir "${node_dir}/$port" --root-dir "${node_dir}/$port" &
done

# Wait for initialisation.
sleep 12

# Launch authenticator.
sn_authd start --fg &

# Wait for background processes.
wait
