#!/bin/bash

if [[ "$(docker exec -i gluster mount | grep -c /mnt/myvolume)" == "0" ]]; then
    docker exec -i gluster mkdir -p /mnt/myvolume
    docker exec -i gluster mount.glusterfs 127.0.0.1:/myvolume /mnt/myvolume
fi
