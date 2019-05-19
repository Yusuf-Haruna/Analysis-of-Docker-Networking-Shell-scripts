#!/bin/sh 

# This is pgbench benchmark which is postgresql client which runs the benchmark on NAT mode

echo "****** This container runs pgbench which benchmark postgresql server on NAT mode ******"

# Get the IP address of the client machine
ip_client=`hostname -I | awk '{print $1}' | cut -f2 -d:`

# Create the container using postgresql alpine image in NAT mode
docker run -tid --name pgbench_NAT_mode_container_client -e POSTGRES_PASSWORD='' -p ${ip_client}:5432:5432 postgres:alpine

# Initialize the database "template1"
docker exec -i pgbench_NAT_mode_container_client bash <<'EOF' 
pgbench --initialize --scale=10 template1 --host=192.168.122.167 --port=5432 --username=postgres

EOF

echo "************** postgresql NAT mode test starts ******************"
echo "Mode" "," "latency average (ms) " "," "latency stddev (ms) "  > postgresql_NAT_mode_result.xlsm

# Perform the test 30 times using pgbench benchmark
for i in `seq 1 30`
do
docker exec -i pgbench_NAT_mode_container_client bash <<'EOF' >> postgresql_NAT_mode_result.xlsm
pgbench --client=20 --jobs=4 --transactions=5 --rate=300 template1 --host=192.168.122.167 --port 5432 --username=postgres > x.txt
echo "NAT mode" "," `(cat x.txt | head -n 8 | tail -n 1 | awk '{print $4}')` "," `(cat x.txt | head -n 9 | tail -n 1 | awk '{print $4}')`
exit
EOF
done

# Calculate average of the results 
echo "Average" "," `cat postgresql_NAT_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` "," `cat postgresql_NAT_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'` >> postgresql_NAT_mode_result.xlsm


