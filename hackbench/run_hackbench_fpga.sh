ulimit -n 65536

ARCH=$1
echo "ARCH chosen: " ${ARCH}

PLATFORM=$2
echo "Platform chosen: " ${PLATFORM}

TYPE=$3
echo "Type chosen: " ${TYPE}

if [[ ${ARCH} != "" ]]; then
    if [[ ${TYPE} == "perf" ]]; then
        #Collecting perf stat
        rm -rf  hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 8 process 1000 2>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 16 process 1000 2>>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 24 process 1000 2>>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 32 process 1000 2>>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 64 process 1000 2>>hackbench.${ARCH}.stat

        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 8 thread 1000 2>>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 16 thread 1000 2>>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 24 thread 1000 2>>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 32 thread 1000 2>>hackbench.${ARCH}.stat
        perf stat -e instructions,cycles ./hackbench.${ARCH}.elf 64 thread 1000 2>>hackbench.${ARCH}.stat
    else
        #Collecting ARM PM events
        echo "Add support if needed"
    fi
fi

grep  "instructions" hack*${ARCH}*stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
grep  "cycles" hack*${ARCH}*stat | grep -Eo '[0-9,]*'
grep  "seconds time elapsed" hack*${ARCH}*stat | grep -Eo '[0-9]*\.[0-9]*'
#grep  "Time" hack*score | grep -Eo '[0-9]*\.[0-9]*'


#####Running taskset variant
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 8 process 1000 2>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 16 process 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 24 process 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 32 process 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 64 process 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 128 process 1000 2>>hackbench.${ARCH}.stat

#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 8 thread 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 16 thread 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 24 thread 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 32 thread 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 64 thread 1000 2>>hackbench.${ARCH}.stat
#taskset 0xff perf stat -C 0-7 -e instructions,cycles ./hackbench.${ARCH}.elf 128 thread 1000 2>>hackbench.${ARCH}.stat

