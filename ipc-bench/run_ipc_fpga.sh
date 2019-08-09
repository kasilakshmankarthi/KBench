TARGET=$1
echo "Target chosen:" ${TARGET}

TYPE=$2
echo "Type chosen:" ${TYPE}

if [[ ${TARGET} != "" ]]; then
    if [[ ${TYPE} == "perf" ]]; then
        #Collecting perf stat
        rm -rf ipc_16B.stat
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/tcp_lat.${TARGET}.elf 16 10000 2>ipc_16B.stat
        echo ""
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/unix_lat.${TARGET}.elf 16 10000 2>>ipc_16B.stat
        echo ""
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/pipe_lat.${TARGET}.elf 16 10000 2>>ipc_16B.stat
        echo ""

        rm -rf ipc_1500B.stat
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/tcp_lat.${TARGET}.elf 1500 10000 2>ipc_1500B.stat
        echo ""
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/unix_lat.${TARGET}.elf 1500 10000 2>>ipc_1500B.stat
        echo ""
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/pipe_lat.${TARGET}.elf 1500 10000 2>>ipc_1500B.stat
        echo ""

        rm -rf ipc_64KB.stat
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/tcp_lat.${TARGET}.elf 65536 10000 2>ipc_64KB.stat
        echo ""
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/unix_lat.${TARGET}.elf 65536 10000 2>>ipc_64KB.stat
        echo ""
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./binaries/pipe_lat.${TARGET}.elf 65536 10000 2>>ipc_64KB.stat
        echo ""
    else
        #Collecting ARM PM events
        ./binaries/runAllSaphira_counters_instr_v1.sh "cp 1 2 3 4 5 6 7" "-C 1 /qipc-bench/binaries/tcp_.${TARGET}.elf.aarch64.elf 16 10000 1 " "output_tcp.${TARGET}.elf"

        ./binaries/runAllSaphira_counters_instr_v1.sh "cp 1 2 3 4 5 6 7" "-C 1 /qipc-bench/binaries/unix_.${TARGET}.elf.aarch64.elf 16 10000 1 " "output_unix.${TARGET}.elf"

        ./binaries/runAllSaphira_counters_instr_v1.sh "cp 1 2 3 4 5 6 7" "-C 1 /qipc-bench/binaries/pipe_.${TARGET}.elf.aarch64.elf 16 10000 1 " "output_pipe.${TARGET}.elf"
    fi
fi

grep  "instructions" ipc_16B*stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
grep  "cycles" ipc_16B*stat | grep -Eo '[0-9,]*'
grep  "seconds time elapsed" ipc_16B*stat | grep -Eo '[0-9]*\.[0-9]*'

grep  "instructions" ipc_1500B*stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
grep  "cycles" ipc_1500B*stat | grep -Eo '[0-9,]*'
grep  "seconds time elapsed" ipc_1500B*stat | grep -Eo '[0-9]*\.[0-9]*'

grep  "instructions" ipc_64KB*stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
grep  "cycles" ipc_64KB*stat | grep -Eo '[0-9,]*'
grep  "seconds time elapsed" ipc_64KB*stat | grep -Eo '[0-9]*\.[0-9]*'

