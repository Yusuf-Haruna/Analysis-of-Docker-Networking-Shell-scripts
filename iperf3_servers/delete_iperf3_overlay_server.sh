#! /bin/bash

docker rm -f iperf3_VXLAN_container_server
docker network rm my_overlay_network
docker swarm leave -f
rm /home/yusuf/Documents/iperf3_servers/iperf3_VXLAN_token.txt

