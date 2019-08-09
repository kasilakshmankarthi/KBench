#!/bin/sh

TARGET=$1
echo "Target chosen:" ${TARGET}

TYPE=$2
echo "Type chosen:" ${TYPE}

if [[ ${TARGET} != "" ]]; then
    if [[ ${TYPE} == "perf" ]]; then
        #Collecting perf stat for configuration close to model run
        rm -rf  tmphammer.${TARGET}.stat
        taskset 0x1  perf stat -C 0 -e instructions,cycles ./tmphammer.${TARGET}.elf 1 50000 2>tmphammer.${TARGET}.stat
        taskset 0x1  perf stat -C 0 -e instructions,cycles ./tmphammer.${TARGET}.elf 2 50000 2>>tmphammer.${TARGET}.stat
        taskset 0x3  perf stat -C 0-1 -e instructions,cycles ./tmphammer.${TARGET}.elf 4 50000 2>>tmphammer.${TARGET}.stat
        taskset 0xff perf stat -C 0-7 -e instructions,cycles ./tmphammer.${TARGET}.elf 16 50000 2>>tmphammer.${TARGET}.stat
    else
        #Collecting ARM PM events
        ./runAllSaphira_counters_instr_v1.sh "cp 0" "-C 0 tmphammer.${TARGET}.elf 1 50000" "output_ths"

        ./runAllSaphira_counters_instr_v1.sh "cp 0 1 2 3 4 5 6 7" "-C 0-7 tmphammer.${TARGET}.elf 16 50000" "output_thm"
    fi
fi

grep  "instructions" tmph*.${TARGET}.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
grep  "cycles" tmph*.${TARGET}.stat | grep -Eo '[0-9,]*'
grep  "seconds time elapsed" tmph*${TARGET}.stat | grep -Eo '[0-9]*\.[0-9]*'
grep  "microseconds" tmph*.${TARGET}.stat | grep -Eo '[0-9]*\.[0-9]*'
