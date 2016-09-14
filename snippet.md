Ansible Inventory

```
[gluster-main]
192.168.56.101

[gluster-node]
192.168.56.102
192.168.56.103
```

Setup Script

```bash
# get required package
apt-get update
apt-get install -y glusterfs-server glusterfs-client golang

# setup go
mkdir $HOME/.go
echo "export GOPATH=$HOME/.go" >> $HOME/.bashrc

# download gluster volume driver for docker
go get github.com/amarkwalder/docker-volume-glusterfs

# setup glusterfs-server
# add node 2 3 to trusted peer
gluster peer probe 192.168.56.102
gluster peer probe 192.168.56.103

# create replicated volume on all node
gluster volume create myvolume \
    replica 3 \
    192.168.56.101:/opt/gluster/myvolume \
    192.168.56.102:/opt/gluster/myvolume \
    192.168.56.103:/opt/gluster/myvolume \
    force

gluster volume start myvolume
```

Mount volume on each node

```bash
mkdir -p /mnt/myvolume
mount.glusterfs 127.0.0.1:/myvolume /mnt/myvolume/

# start docker volume driver
# @TODO: make this command run in daemon mode
docker-volume-glusterfs -servers 192.168.56.101:192.168.56.102:192.168.56.103
```

Test it

```bash
docker run -it \
    --volume-driver glusterfs \
    --volume myvolume:/data \
    alpine bash
```
