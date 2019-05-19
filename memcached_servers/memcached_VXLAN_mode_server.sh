#! /bin/bash

# This is the server for the memcached test in Default overlay (VXLAN) mode
echo "********* This is the memcached server in the Default overlay (VXLAN) mode case **********"

# Get the IP address of the server (the VM)
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo "The IP address of the server is: " $ipserver

# Create the swarm as a manager and store the token in a file for worker to join 
docker swarm init --advertise-addr=$ipserver | head -n 5 | tail -n 1 > memcached_VXLAN_token.txt

# Create an overlay network
docker network create --driver=overlay --attachable my_overlay_network

# Create the container and connect to "my_overlay_net" network
docker run -itd --name memcached_VXLAN_container_server --network my_overlay_network ubuntu:16.04

# Get the IP of the container
docker exec -i memcached_VXLAN_container_server /bin/bash << 'EOF' >> memcached_VXLAN_token.txt
hostname -i | awk '{print $1}'
EOF

# Install memcached in the conatiner
docker exec -i memcached_VXLAN_container_server /bin/bash << 'EOF'
apt-get update
apt-get install memcached -y
service memcached start

memcached -l $(hostname -i | awk '{print $1}' | cut -f2 -d:) -p 11211 -u memcache

EOF




