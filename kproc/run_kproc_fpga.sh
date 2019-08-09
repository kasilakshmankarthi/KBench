TARGET=$1
echo "Target chosen:" ${TARGET}

TYPE=$2
echo "Type chosen:" ${TYPE}

#Note mask starts from 1
#Note -C starts from 0. So 1 less than mask.

if [[ ${TARGET} != "" ]]; then
    if [[ ${TYPE} == "perf" ]]; then
        #Collecting perf stat
        rm -rf  qproc.${TARGET}.stat

        ########proc tests
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./qproc.${TARGET}.elf -N 25000 procedure 2>qproc.${TARGET}.stat
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./qproc.${TARGET}.elf -N 25000 fork 2>>qproc.${TARGET}.stat
        taskset 0x2 perf stat -C 1 -e instructions,cycles ./qproc.${TARGET}.elf -N 25000 exec 2>>qproc.${TARGET}.stat

     else
        #Collecting ARM PM events
        ./runAllSaphira_counters_instr_v1.sh "cp 1 2 3 4 5 6 7" "-C 1 /qipc-bench/binaries/tcp_lat.aarch64.elf 1500 10000 1 1 0" "output_tcp_lat"

        ./runAllSaphira_counters_instr_v1.sh "cp 1 2 3 4 5 6 7" "-C 1 /qipc-bench/binaries/unix_lat.aarch64.elf 1500 10000 1 1 0" "output_unix_lat"

        ./runAllSaphira_counters_instr_v1.sh "cp 1 2 3 4 5 6 7" "-C 1 /qipc-bench/binaries/pipe_lat.aarch64.elf 1500 10000 1 1 0" "output_pipe_lat"
    fi
fi

grep  "instructions" qproc.${TARGET}.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
echo ""
grep  "cycles" qproc.${TARGET}.stat | grep -Eo '[0-9,]*'
echo ""
grep  "seconds time elapsed" qproc.${TARGET}.stat | grep -Eo '[0-9]*\.[0-9]*'
echo ""
grep  " ns" qproc.${TARGET}.stat | grep -Eo '[0-9]+'
echo ""
