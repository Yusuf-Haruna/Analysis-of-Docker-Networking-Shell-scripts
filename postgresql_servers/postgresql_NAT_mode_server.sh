#! /bin/sh

# This is the server for the postgresql database test in host mode
echo "********* This is the postgresql database server in the host mode case **********"

# Get the IP address of the server machine
ipserver=`hostname -I | awk '{print $1}' | cut -f2 -d:`

echo " >>>>>>> The IP address of the server is: " $ipserver

# Create the container in NAT mode using postgresql alpine image which runs postgresql server automatically
docker run -tid --name postgresql_NAT_mode_container_server -e POSTGRES_PASSWORD='' -p ${ipserver}:5432:5432 postgres:alpine
