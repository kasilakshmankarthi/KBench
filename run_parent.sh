SOC=$1
echo "Target run" ${SOC}

ifconfig lo up
cp /qipc-bench/binaries/perf /usr/bin

perf stat -d md5sum run_parent.sh
perf stat -d sleep 1s

cd /qipc-bench/binaries
./run_qipc_fpga.sh aarch64 perf 1
./run_qipc_fpga.sh aarch64 perf 2

cd /ipc-bench
./run_ipc_fpga.sh aarch64 perf

cd /lmb
./run_lmbench_${SOC}.sh aarch64 perf

cd /hackbench
./run_hackbench_${SOC}.sh aarch64 perf

