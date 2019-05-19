#!/bin/sh 

# This is pgbench benchmark which is postgresql client that runs the benchmark on weave mode
echo "******* This container runs pgbench which benchmark postgresql server on weave mode ******"

# Install weave in the client machine
wget -O /usr/local/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/local/bin/weave

# Launch weave using the IP address of the server machine
weave launch 192.168.122.167

# Create container on the client and then attach it to the weave
docker run -tid --name pgbench_weave_mode_container_client -e POSTGRES_PASSWORD='' postgres:alpine
weave attach pgbench_weave_mode_container_client

# Initialize the database "template1"
docker exec -i pgbench_weave_mode_container_client bash <<'EOF' 
pgbench --initialize --scale=10 template1 --host=10.32.0.1 --port=5432 --username=postgres

EOF

echo "************** postgresql weave mode test starts ******************"
echo "Mode" "," "latency average (ms) " "," "latency stddev (ms) "  > postgresql_weave_mode_result.xlsm

# Perform the test 30 times using pgbench benchmark
for i in `seq 1 30`
do
docker exec -i pgbench_weave_mode_container_client bash <<'EOF' >> postgresql_weave_mode_result.xlsm
pgbench --client=20 --jobs=4 --transactions=5 --rate=300 template1 --host=10.32.0.1 --port 5432 --username=postgres > x.txt
echo "Weave mode" "," `(cat x.txt | head -n 8 | tail -n 1 | awk '{print $4}')` "," `(cat x.txt | head -n 9 | tail -n 1 | awk '{print $4}')`
exit
EOF
done

# Calculate average of the results 
echo "Average" "," `cat postgresql_weave_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` "," `cat postgresql_weave_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'` >> postgresql_weave_mode_result.xlsm
