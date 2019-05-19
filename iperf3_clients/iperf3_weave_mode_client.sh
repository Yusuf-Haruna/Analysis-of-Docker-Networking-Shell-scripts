#! /bin/sh

# This is the client of iperf3 test in weave mode
echo "********* This is the iperf3 client in weave mode case *********"

# Install weave in the client machine
wget -O /usr/local/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/local/bin/weave

# Launch weave using the IP address of the server machine
weave launch 192.168.122.167

# Create container on the client and then attach it to the weave
docker run -itd --name iperf3_weave_container_client ubuntu:16.04
weave attach iperf3_weave_container_client

# Install iperf3 in the container
docker exec -i iperf3_weave_container_client bash << 'EOF'
apt-get update
apt-get install iperf3 -y

EOF

echo "************ iperf3 WEAVE MODE TEST STARTS *****************" 
echo "Mode" "," "Throughput TCP MBps" "," "Throughput UDP MBps " > iperf3_weave_mode_result.xlsm

for i in `seq 1 30`
do
# TCP and UDP throughput test
docker exec -i iperf3_weave_container_client bash <<'EOF' >> iperf3_weave_mode_result.xlsm
echo "Host mode" "," `(iperf3 -c 10.32.0.1 -p 44440 -b 0 -f M | head -n 16 |  tail -n 1 | awk '{print $7}')` "," `(iperf3 -c 10.32.0.1 -p 44441 -b 0 --udp -f M | head -n 16 |  tail -n 1 | awk '{print $7}')`
exit
EOF
done

# Calculate average of the results
echo 'Average' ',' `cat iperf3_weave_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` ',' `cat iperf3_weave_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`>> iperf3_weave_mode_result.xlsm


