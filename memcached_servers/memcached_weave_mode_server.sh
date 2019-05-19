#! /bin/bash

# This is the server for the memcached test in weave mode
echo "********* This is the memcached server in the weave mode case **********"

# Get the IP address of the server 
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo "The IP address of the server is: " $ipserver

# Install weave in the server machine
wget -O /usr/local/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/local/bin/weave

# Launch weave
weave launch

# Create a container on the server and then attach it to the weave which returns the IP of the container
docker run -itd --name memcached_weave_container_server ubuntu:16.04
weave attach memcached_weave_container_server | awk '{print $1}' > memcached_weave_container_ip.txt

# Install memcached in the container
docker exec -i memcached_weave_container_server /bin/bash << 'EOF'
apt-get update
apt-get install memcached -y
service memcached start

memcached -l $(hostname -I | awk '{print $2}' | cut -f2 -d:) -p 11211 -u memcache

EOF
