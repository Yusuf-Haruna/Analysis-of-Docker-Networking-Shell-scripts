#! /bin/sh

# This is the server for the postgresql database test in weave mode
echo "********* This is the postgresql database server in the weave mode case **********"

# Get the IP address of the server machine
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo " >>>>>>> The IP address of the server is: " $ipserver

# Install weave in the server machine
wget -O /usr/local/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/local/bin/weave

# Launch weave
weave launch

# Create a container on the server and then attach it to the weave which returns the IP of the container
docker run -tid --name postgresql_weave_mode_container_server -e POSTGRES_PASSWORD='' postgres:alpine
weave attach postgresql_weave_mode_container_server | awk '{print $1}' > postgresql_weave_container_ip.txt


