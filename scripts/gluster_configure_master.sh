#!/bin/bash

# forward gluster command to docker container
gluster() {
    docker exec -i gluster gluster "$@"
}

MASTER_IP="$1"
NODE_IP="$2"
VOLUME=myvolume

# create volume

if [[ "`gluster volume list | grep -c $VOLUME`" == "0" ]]; then
    # minimum replica is 2, we need to start with atleast 1 trusted peer in cluster
    gluster peer probe $NODE_IP
    gluster volume create $VOLUME replica 2 $MASTER_IP:/gluster $NODE_IP:/gluster force
    gluster volume start $VOLUME

    # we should stop here, since this node is first peer in cluster
    # and we included them in the replicated volume
    exit 0
fi

# add another node to trusted peer, and add brick to volume

if [[ "`gluster peer status | grep -c $NODE_IP`" == "0" ]]; then
    gluster peer probe $NODE_IP

    COUNT=`gluster volume info $VOLUME | grep -P 'Brick[0-9]+:' | wc -l`
    gluster volume add-brick $VOLUME replica `expr $COUNT + 1` $NODE_IP:/gluster force
fi

exit 0

# snipppet to reset all, then you can start the play again
#docker rm -f gluster && rm -rf /opt/gluster/*
