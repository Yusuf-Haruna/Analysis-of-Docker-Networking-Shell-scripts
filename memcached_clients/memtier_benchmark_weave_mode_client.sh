#! /bin/sh

# This is the client of memcached server test in weave mode
echo "********* This is the memcached server client in weave mode case *********"

# Install weave in the client machine
wget -O /usr/local/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/local/bin/weave

# Launch weave using the IP address of the server machine
weave launch 192.168.122.167

# Create container on the client and then attach it to the weave
docker run -itd --name memtier_benchmark_weave_mode_container_client ubuntu:16.04
weave attach memtier_benchmark_weave_mode_container_client

# Install memtier_benchmark in the container
docker exec -i memtier_benchmark_weave_mode_container_client bash << 'EOF'
apt-get update
apt-get install -yy build-essential autoconf automake libpcre3-dev libevent-dev pkg-config zlib1g-dev git libboost-all-dev cmake flex
git clone https://github.com/RedisLabs/memtier_benchmark.git
cd memtier_benchmark/
autoreconf -ivf && ./configure && make && make install

EOF

echo "************** MEMCACHED WEAVE MODE TEST STARTS ******************" 
echo "Mode" "," "Throughput KBps " "," "Latency msec " "," "SET latency msec " "," "GET latency msec " > memcached_weave_mode_result.xlsm

# Perform the test 30 times
for i in `seq 1 30`
do
docker exec -i memtier_benchmark_weave_mode_container_client bash <<'EOF' >> memcached_weave_mode_result.xlsm
memtier_benchmark --server=10.32.0.1 --port=11211 --protocol=memcache_text --clients=50 --threads=4 --ratio=1:10 --test-time=1 > x.txt
echo "Weave mode" "," `(cat x.txt | head -n 13 | tail -n 8 | tail -n 1 | awk '{print $6 " , " $5}')` "," `(cat x.txt | head -n 13 | tail -n 8 | head -n 5 | tail -n 1 | awk '{print $5}')` "," `(cat x.txt | head -n 13 | tail -n 8 | head -n 6 | tail -n 1 | awk '{print $5}')`
exit
EOF
done

# Calculate average of the results
echo "Average" "," `cat memcached_weave_mode_result.xlsm | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` "," `cat memcached_weave_mode_result.xlsm | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'` "," `cat memcached_weave_mode_result.xlsm | awk -F',' '{sum+=$4} END {print sum/(NR-1)}'` "," `cat memcached_weave_mode_result.xlsm | awk -F',' '{sum+=$5} END {print sum/(NR-1)}'` >> memcached_weave_mode_result.xlsm
