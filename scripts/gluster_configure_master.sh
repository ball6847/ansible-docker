#!/bin/bash

#set -e

SELF_IP="$1"
NODE_IP="$2"
SELF_PROBE_NEEDED=("$(docker exec -i gluster gluster peer status | grep -c $SELF_IP)" == "0")
NODE_PROBE_NEEDED=("$(docker exec -i gluster gluster peer status | grep -c $NODE_IP)" == "0")
VOLUME=myvolume
NO_VOLUME=("$(docker exec -i gluster gluster volume list | grep -c $VOLUME)" == "0")

# add node to cluster

if [[ $SELF_PROBE_NEEDED ]]; then
    docker exec -i gluster gluster peer probe $SELF_IP
fi

if [[ $NODE_PROBE_NEEDED ]]; then
    docker exec -i gluster gluster peer probe $NODE_IP
fi

# create volume

if [[ $NO_VOLUME ]]; then
    docker exec -i gluster gluster volume create $VOLUME transport tcp $SELF_IP:/gluster force
    docker exec -i gluster gluster volume start $VOLUME
fi

