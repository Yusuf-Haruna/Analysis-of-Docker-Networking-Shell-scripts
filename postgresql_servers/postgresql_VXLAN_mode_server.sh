#! /bin/sh

# This is the server for the postgresql database test in Default overlay (VXLAN) mode
echo "********* This is the postgresql database server in the Default overlay (VXLAN) mode case **********"

# Get the IP address of the server machine
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo " >>>>>>> The IP address of the server is: " $ipserver

# Create the swarm as a manager and store the token in a file for worker to join 
docker swarm init --advertise-addr=$ipserver | head -n 5 | tail -n 1 > postgresql_VXLAN_token.txt

# Create an overlay network
docker network create --driver=overlay --attachable my_overlay_network

# Create the container and connect to "my_overlay_network" network
docker run -tid --name postgresql_VXLAN_mode_container_server --network my_overlay_network -e POSTGRES_PASSWORD='' postgres:alpine

# Get the IP of the container
docker exec -i postgresql_VXLAN_mode_container_server /bin/bash << 'EOF' >> postgresql_VXLAN_token.txt
hostname -i | awk '{print $1}'
EOF




