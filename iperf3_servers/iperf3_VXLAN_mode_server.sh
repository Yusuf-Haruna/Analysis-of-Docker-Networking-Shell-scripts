#! /bin/bash

# This is the server for the iperf3 test in Default overlay (VXLAN) mode
echo "****** This is the iperf3 server in the Default overlay (VXLAN) mode case *******"

# Get the IP address of the server (the VM)
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo "the IP address of the server is: " $ipserver

# Create the swarm as a manager and store the token in a file for worker to join 
docker swarm init --advertise-addr=$ipserver | head -n 5 | tail -n 1 > iperf3_VXLAN_token.txt

# Create an overlay network
docker network create --driver=overlay --attachable my_overlay_network

# Create the container and connect to "my_overlay_net" network
docker run -itd --name iperf3_VXLAN_container_server --network my_overlay_network ubuntu:16.04

# Get the IP of the container
docker exec -i iperf3_VXLAN_container_server /bin/bash << 'EOF' >> iperf3_VXLAN_token.txt
hostname -i | awk '{print $1}'
EOF

# Install iperf3 in the container
docker exec -i iperf3_VXLAN_container_server /bin/bash << 'EOF'
apt-get update 
apt-get install iperf3 -y
apt-get install parallel -y

parallel ::: "iperf3 -s $(hostname -i | awk '{print $1}'| cut -f2 -d:) -p 33330" "iperf3 -s $(hostname -i | awk '{print $1}'| cut -f2 -d:) -p 33331"

EOF
