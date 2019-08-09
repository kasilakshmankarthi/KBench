echo "Please run with only 8 CPU cores"
#./hotplug.sh 8 47 off

sudo bash -c 'ulimit -n 65536'

TARGET=$1
echo "Target chosen:" ${TARGET}

TYPE=$2
echo "Type chosen:" ${TYPE}

if [[ ${TARGET} != "" ]]; then
    if [[ ${TYPE} == "perf" ]]; then
        #Collecting perf stat
        rm -rf  hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 8 process 1000 2>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 16 process 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 24 process 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 32 process 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 64 process 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 128 process 1000 2>>hackbench.${TARGET}.stat

        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 8 thread 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 16 thread 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 24 thread 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 32 thread 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 64 thread 1000 2>>hackbench.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${TARGET}.elf 128 thread 1000 2>>hackbench.${TARGET}.stat
    else
        #Collecting ARM PM events
        ./runAllSaphira_counters_instr_v1.sh "cp 0" "-C 0 hackbench.${TARGET}.elf 1 50000" "output_ths"

        ./runAllSaphira_counters_instr_v1.sh "cp 0 1 2 3 4 5 6 7" "-C 0-7 hackbench.${TARGET}.elf 16 50000" "output_thm"
    fi
fi

grep  "instructions" hack*${TARGET}*stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
grep  "cycles" hack*${TARGET}*stat | grep -Eo '[0-9,]*'
grep  "seconds time elapsed" hack*${TARGET}*stat | grep -Eo '[0-9]*\.[0-9]*'
#grep  "Time" hack*score | grep -Eo '[0-9]*\.[0-9]*'
