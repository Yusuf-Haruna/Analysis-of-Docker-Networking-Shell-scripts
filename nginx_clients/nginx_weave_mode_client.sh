#! /bin/sh

# This is the client of nginx server test in weave mode
echo "********* This is the nginx server client in weave mode case *********"

# Install weave in the client machine
wget -O /usr/local/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/local/bin/weave

# Launch weave using the IP address of the server machine
weave launch 192.168.122.167

# Create container on the client and then attach it to the weave
docker run -itd --name wrk_benchmark_weave_mode_container_client ubuntu:16.04
weave attach wrk_benchmark_weave_mode_container_client

# Install wrk benchmark in the container  
docker exec -i wrk_benchmark_weave_mode_container_client bash <<EOF 
apt-get update
apt-get install -y build-essential libssl-dev git zlib1g-dev
git clone https://github.com/giltene/wrk2.git
cd wrk2
make
cp wrk /usr/local/bin
EOF


echo "************** nginx weave mode 1MB html file test starts ******************"
echo "Mode" "," "Avg latency " "," "Stdev " "," "Max " "," "+/- Stdev " > nginx_1MB_weave_mode_result.xlsm

# Perform the test 30 times for 1MB html file
for i in `seq 1 30`
do
docker exec -i wrk_benchmark_weave_mode_container_client bash <<'EOF' >> nginx_1MB_weave_mode_result.xlsm
echo "Weave mode" "," `(wrk --thread 2 --connections 100 --rate 3000 http://10.32.0.1:80/weave_one_MB_index.html | head -n 4 | tail -n 1 | awk '{print $2 " , "$3 " , " $4 " , " $5}')` 
exit
EOF
done

echo "************** nginx weave mode 1KB html file test starts ******************"
echo "Mode" "," "Avg latency " "," "Stdev " "," "Max " "," "+/- Stdev " > nginx_1KB_weave_mode_result.xlsm

# Perform the test 30 times for 1KB html file
for i in `seq 1 30`
do
docker exec -i wrk_benchmark_weave_mode_container_client bash <<'EOF' >> nginx_1KB_weave_mode_result.xlsm
echo "Weave mode" "," `(wrk --thread 2 --connections 100 --rate 60000 http://10.32.0.1:80/weave_one_KB_index.html | head -n 4 | tail -n 1 | awk '{print $2 " , "$3 " , " $4 " , " $5}')` 
exit
EOF
done

# Calculate average of the results (1MB file)
echo "Average" "," `cat nginx_1MB_weave_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` "," `cat nginx_1MB_weave_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'` "," `cat nginx_1MB_weave_mode_result.xlsm | awk -F',' '{sum+=$4} END {print sum/(NR-1)}'` "," `cat nginx_1MB_weave_mode_result.xlsm | awk -F',' '{sum+=$5} END {print sum/(NR-1)}'` >> nginx_1MB_weave_mode_result.xlsm

# Calculate average of the results (1KB file)
echo "Average" "," `cat nginx_1KB_weave_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` "," `cat nginx_1KB_weave_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'` "," `cat nginx_1KB_weave_mode_result.xlsm | awk -F',' '{sum+=$4} END {print sum/(NR-1)}'` "," `cat nginx_1KB_weave_mode_result.xlsm | awk -F',' '{sum+=$5} END {print sum/(NR-1)}'` >> nginx_1KB_weave_mode_result.xlsm

