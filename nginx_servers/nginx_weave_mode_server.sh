#! /bin/bash

# This is the server for the nginx test in weave mode
echo "********* This is the nginx server in the weave mode case **********"

# Get the IP address of the server 
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo " >>>>>>>>>> The IP address of the server is: " $ipserver

# Install weave in the server machine
wget -O /usr/local/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/local/bin/weave

# Launch weave
weave launch

# Create a container on the server and then attach it to the weave which returns the IP of the container
docker run -itd --name nginx_weave_mode_container_server ubuntu:16.04
weave attach nginx_weave_mode_container_server | awk '{print $1}' > nginx_weave_container_ip.txt

# Install nginx in the container and create two html files of size 1MB and 1KB and then start nginx server
docker exec -i nginx_weave_mode_container_server /bin/bash << 'EOF'
apt-get update
apt install nginx -y
cd /usr/share/nginx/html
dd if=/dev/zero of=weave_one_MB_index.html count=1024 bs=1024  # create 1MB html file
dd if=/dev/zero of=weave_one_KB_index.html count=4 bs=256  # create 1KB html file
cd /
service nginx start

EOF


