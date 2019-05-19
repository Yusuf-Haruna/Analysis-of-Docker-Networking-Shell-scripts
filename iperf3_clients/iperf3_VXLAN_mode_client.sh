#! /bin/sh

# This is the client of iperf3 test in Default overlay (VXLAN) mode
echo "******* This is the iperf3 client in Default overlay (VXLAN) mode case *******"

# Joining the swarm
docker swarm join --token SWMTKN-1-3fypgclh87uss8kzjdc2go1lxlq9vph7yq994df3s4njowdwu3-58lrvlvjb8d9e7oa5lw2h5hhj 192.168.122.167:2377

# Create the container and connect it to the overlay network created in the master
docker run -itd --name iperf3_VXLAN_container_client --network my_overlay_network ubuntu:16.04

# Install iperf3 in the container
docker exec -i iperf3_VXLAN_container_client bash << 'EOF'
apt-get update
apt-get install iperf3 -y

EOF

echo "************** iperf3 Default overlay MODE TEST STARTS ******************" 
echo "Mode" "," "Throughput TCP MBps" "," "Throughput UDP MBps " > iperf3_VXLAN_mode_result.xlsm

for i in `seq 1 30`
do
# TCP and UDP throughput test
docker exec -i iperf3_VXLAN_container_client bash <<'EOF' >> iperf3_VXLAN_mode_result.xlsm
echo "Def. overlay mode" "," `(iperf3 -c 10.0.0.2 -p 33330 -b 0 -f M | head -n 16 |  tail -n 1 | awk '{print $7}')` "," `(iperf3 -c 10.0.0.2 -p 33331 -b 0 --udp -f M | head -n 16 |  tail -n 1 | awk '{print $7}')`
exit
EOF
done

# Calculate average of the results
echo 'Average' ',' `cat iperf3_VXLAN_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` ',' `cat iperf3_VXLAN_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`>> iperf3_VXLAN_mode_result.xlsm


