#! /bin/bash

# This is the server for the iperf3 test in host mode
echo "********* This is the iperf3 server in the host mode case **********"

# Get the IP address of the server (the VM)
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo "the IP address of the server is: " $ipserver

# Create the container in host mode
docker run -tid --name iperf3_host_mode_container_server --network host ubuntu:16.04

# Install iperf3 in the conatiner
docker exec -i iperf3_host_mode_container_server /bin/bash << 'EOF'
apt-get update 
apt-get install iperf3 -y

apt-get install parallel -y

parallel ::: "iperf3 -s $(hostname -I | awk '{print $2}'| cut -f2 -d:) -p 11110" "iperf3 -s $(hostname -I | awk '{print $2}'| cut -f2 -d:) -p 11111"

EOF
