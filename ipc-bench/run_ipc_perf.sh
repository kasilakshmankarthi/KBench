TARGET=$1
echo "Target chosen:" ${TARGET}

if [[ ${TARGET} != "" ]]; then
        taskset 0x2 perf record ./binaries/tcp_lat.${TARGET}.elf 16 10000
        perf report > report_tcp_lat_16_10000.txt
        perf annotate --vmlinux vmlinux > annot_tcp_lat_16_10000.txt

        taskset 0x2 perf record ./binaries/tcp_lat.${TARGET}.elf 1500 10000
        perf report > report_tcp_lat_1500_10000.txt
        perf annotate --vmlinux vmlinux > annot_tcp_lat_1500_10000.txt


        taskset 0x2 perf record ./binaries/tcp_lat.${TARGET}.elf 65536 10000
        perf report > report_tcp_lat_65536_10000.txt
        perf annotate --vmlinux vmlinux > annot_tcp_lat_65536_10000.txt
fi
