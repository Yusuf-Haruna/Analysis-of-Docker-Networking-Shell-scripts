#! /bin/bash

# This is the server for the iperf3 test in NAT mode
echo "********* This is the iperf3 server in the NAT mode case **********"

# Get the IP address of the server (the VM)
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo "The IP address of the server is: " $ipserver

# Create the container in host mode
docker run -tid --name iperf3_NAT_mode_container_server -p22220:22220 -p22220:22220/udp ubuntu:16.04

# Install iperf3 in the conatiner
docker exec -i iperf3_NAT_mode_container_server /bin/bash << 'EOF'
apt-get update 
apt-get install iperf3 -y

apt-get install parallel -y

#parallel ::: "iperf3 -s $(hostname -I | awk '{print $1}'| cut -f2 -d:) -p 22220" "iperf3 -s $(hostname -I | awk '{print $1}'| cut -f2 -d:) -p 22221"
iperf3 -s $(hostname -I | awk '{print $1}'| cut -f2 -d:) -p 22220
EOF
