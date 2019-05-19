#! /bin/bash

# This is the server for the nginx test in Default overlay (VXLAN) mode
echo "********* This is the nginx server in the Default overlay (VXLAN) mode case **********"

# Get the IP address of the server machine
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo " >>>>>>>>>> The IP address of the server is: " $ipserver

# Create the swarm as a manager and store the token in a file for worker to join 
docker swarm init --advertise-addr=$ipserver | head -n 5 | tail -n 1 > nginx_VXLAN_token.txt

# Create an overlay network
docker network create --driver=overlay --attachable my_overlay_network

# Create the container and connect to "my_overlay_network" network
docker run -itd --name nginx_VXLAN_mode_container_server --network my_overlay_network ubuntu:16.04

# Get the IP of the container
docker exec -i nginx_VXLAN_mode_container_server /bin/bash << 'EOF' >> nginx_VXLAN_token.txt
hostname -i | awk '{print $1}'
EOF

# Install nginx in the container and create two html files of size 1MB and 1KB and then start nginx server
docker exec -i nginx_VXLAN_mode_container_server /bin/bash << 'EOF'
apt-get update
apt install nginx -y
cd /usr/share/nginx/html
dd if=/dev/zero of=VXLAN_one_MB_index.html count=1024 bs=1024  # create 1MB html file
dd if=/dev/zero of=VXLAN_one_KB_index.html count=4 bs=256  # create 1KB html file
cd /
service nginx start

EOF
