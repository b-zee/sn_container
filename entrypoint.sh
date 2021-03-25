#!/bin/sh

node_dir="${HOME}/.safe/node"
mkdir --parents "${node_dir}"

# Genesis node.
sn_node --local --local-port=12000 --root-dir "${node_dir}/12000" --first &

# Regular nodes connecting to genesis.
for port in $(seq 12001 12011); do
    sleep 1
    sn_node --local --local-port=$port --root-dir "${node_dir}/$port" --hard-coded-contacts='["127.0.0.1:12000"]' &
done

# Wait for initialisation.
sleep 12

# Launch authenticator.
sn_authd start --fg &

# Wait for background processes.
wait
