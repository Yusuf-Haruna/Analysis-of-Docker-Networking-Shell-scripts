#! /bin/bash

docker rm -f nginx_VXLAN_mode_container_server
docker network rm my_overlay_network
docker swarm leave -f
rm /home/yusuf/Documents/nginx_servers/nginx_VXLAN_token.txt
