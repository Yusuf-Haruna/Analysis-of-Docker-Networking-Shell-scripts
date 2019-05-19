#! /bin/bash

# This is the server for the memcached test in host mode
echo "********* This is the memcached server in the host mode case **********"

# Get the IP address of the server (the VM)
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo "the IP address of the server is: " $ipserver

# Create the container in host mode
docker run -tid --name memcached_host_mode_container_server --network host ubuntu:16.04

# Install memcached in the conatiner
docker exec -i memcached_host_mode_container_server /bin/bash << 'EOF'
apt-get update
apt-get install memcached -y
service memcached start
memcached -l 192.168.122.167 -p 11211 -u memcache

EOF
