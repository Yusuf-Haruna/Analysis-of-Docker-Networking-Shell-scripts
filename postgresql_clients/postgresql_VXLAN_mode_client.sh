#!/bin/sh 

# This is pgbench benchmark which is postgresql client that runs the benchmark on Default overlay (VXLAN) mode
echo "******* This container runs pgbench which benchmark postgresql server on Default overlay (VXLAN) mode ******"

# Joining the swarm
docker swarm join --token SWMTKN-1-3ztstb3tbkfq7ah3am5ivqbu48x5s18gh6tmntfqv0n4eyenwd-cfa8podgkcauzbaupblwl5qmu 192.168.122.167:2377

# Create the container using postgresql alpine image and connect it to the overlay network created in the master
docker run -tid --name pgbench_VXLAN_mode_container_client -e POSTGRES_PASSWORD='' --network my_overlay_network postgres:alpine

# Initialize the database "template1"
docker exec -i pgbench_VXLAN_mode_container_client bash <<'EOF' 
pgbench --initialize --scale=10 template1 --host=10.0.0.2 --port=5432 --username=postgres

EOF

echo "************** postgresql Default overlay (VXLAN) mode test starts ******************"
echo "Mode" "," "latency average (ms) " "," "latency stddev (ms) "  > postgresql_VXLAN_mode_result.xlsm

# Perform the test 30 times using pgbench benchmark
for i in `seq 1 30`
do
docker exec -i pgbench_VXLAN_mode_container_client bash <<'EOF' >> postgresql_VXLAN_mode_result.xlsm
pgbench --client=20 --jobs=4 --transactions=5 --rate=300 template1 --host=10.0.0.2 --port 5432 --username=postgres > x.txt
echo "Def. overlay mode" "," `(cat x.txt | head -n 8 | tail -n 1 | awk '{print $4}')` "," `(cat x.txt | head -n 9 | tail -n 1 | awk '{print $4}')`
exit
EOF
done

# Calculate average of the results 
echo "Average" "," `cat postgresql_VXLAN_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` "," `cat postgresql_VXLAN_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'` >> postgresql_VXLAN_mode_result.xlsm

