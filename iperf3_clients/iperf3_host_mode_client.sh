#! /bin/sh

# This is the client of iperf3 test in host mode
echo "********** This is the iperf3 client in host mode case *********"

# Create the container
docker run -tid --name iperf3_host_mode_container_client --network host ubuntu:16.04

# Install iperf3 in the container  
docker exec -i iperf3_host_mode_container_client bash <<EOF 
apt-get update
apt-get install iperf3 -y

EOF


echo "************** iperf3 HOST MODE TEST STARTS ******************" 
echo "Mode" "," "Throughput TCP MBps" "," "Throughput UDP MBps " > iperf3_Host_mode_result.xlsm

for i in `seq 1 30`
do
# TCP and UDP throughput test
docker exec -i iperf3_host_mode_container_client bash <<'EOF' >> iperf3_Host_mode_result.xlsm
echo "Host mode" "," `(iperf3 -c 192.168.122.167 -p 11110 -b 0 -f M | head -n 16 |  tail -n 1 | awk '{print $7}')` "," `(iperf3 -c 192.168.122.167 -p 11111 -b 0 --udp -f M | head -n 16 |  tail -n 1 | awk '{print $7}')`
exit
EOF
done

# Calculate average of the results
echo 'Average' ',' `cat iperf3_Host_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` ',' `cat iperf3_Host_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`>> iperf3_Host_mode_result.xlsm


