#!/bin/bash

TARGET=$1
echo "Target: " ${TARGET}
ITERS=$2
echo "Iters: "${ITERS}
RTC=$3
echo "RTC: " ${RTC}
CORE=$4
echo "CORE_ID: " ${CORE}

INSTS=10

for (( run=1; run<=3; run++ )); do

    rm -rf qctx.${TARGET}.${RTC}.score
    rm -rf qctx.${TARGET}.${RTC}.stat

    for (( instances=1; instances <= $INSTS; instances++ )); do
      perf stat -C ${CORE} --append -o qctx.${TARGET}.${RTC}.stat -e instructions,cycles ./qctx_lat.${TARGET}.elf ${ITERS} ${RTC} ${CORE} ${CORE} 0 >>qctx.${TARGET}.${RTC}.score
    done

    echo ""
    echo "run"${run}
    grep  "instructions" qctx.${TARGET}.${RTC}.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
    echo ""
    grep  "cycles" qctx.${TARGET}.${RTC}.stat | grep -Eo '[0-9,]*'
    echo ""
    grep  "seconds time elapsed" qctx.${TARGET}.${RTC}.stat | grep -Eo '[0-9]*\.[0-9]*'
    echo ""
    grep  "latency" qctx.${TARGET}.${RTC}.score | grep -Eo '[0-9,]*'
done
