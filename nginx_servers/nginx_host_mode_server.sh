#! /bin/bash

# This is the server for the nginx test in host mode
echo "********* This is the nginx server in the host mode case **********"

# Get the IP address of the server machine
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo " >>>>>>> The IP address of the server is: " $ipserver

# Create the container in host mode
docker run -tid --name nginx_host_mode_container_server --network host ubuntu:16.04

# Install nginx in the container and create two html files of size 1MB and 1KB and then start nginx server
docker exec -i nginx_host_mode_container_server /bin/bash << 'EOF'
apt-get update
apt install nginx -y
cd /usr/share/nginx/html
dd if=/dev/zero of=host_one_MB_index.html count=1024 bs=1024  # create 1MB html file
dd if=/dev/zero of=host_one_KB_index.html count=4 bs=256  # create 1KB html file
cd /
service nginx start

EOF




