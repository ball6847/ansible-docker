#!/bin/bash

# forward gluster command to docker container
gluster() {
    docker exec -i gluster gluster "$@"
}

MASTER_IP="$1"
NODE_IP="$2"
VOLUME=myvolume

## create volume

if [[ "$(gluster volume list | grep -c $VOLUME)" == "0" ]]; then
    gluster volume create $VOLUME $MASTER_IP:/gluster force
    gluster volume start $VOLUME
fi

# add node to cluster

if [[ "$(gluster peer status | grep -c $NODE_IP)" == "0" ]]; then
    gluster peer probe $NODE_IP
    gluster volume add-brick $VOLUME $NODE_IP:/gluster force
fi

# snipppet to reset all, then you can start the play again
#docker rm -f gluster && rm -rf /opt/gluster/*
