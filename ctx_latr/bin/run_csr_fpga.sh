ifconfig lo up

TARGET=$1
echo "Target chosen (x86_64/aarch64): " ${TARGET}

TEST=$2
echo "Type chosen (perf/pipe2p/fifo2p/fifo2e)[i/d]: " ${TEST}
len=$((${#TEST}-1))
last=$(echo "${TEST:$len:1}")
echo "Last character in Test: " "${last}"
if [[ ${last} == "i" ]]; then
  dir=$(pwd)/uint64
else
  dir=$(pwd)/double
fi

LOOP=$3
echo "Loop: " ${LOOP}

REPEAT=$4
echo "Repeat: " ${REPEAT}

if [[ ${TARGET} != "" ]]; then
    if [[ ${TEST}  == *"perf"* ]]; then
         #Collecting ARM PM events
         rm -rf pipe_single_*
         ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1  $dir/measureSingle.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT}" "pipe_single_1" > pipe_single_1.log
         ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSingle.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_single_2" > pipe_single_2.log
         ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSingle.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_single_3" > pipe_single_3.log

         rm -rf pipe_switch_*
        ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitch.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT}" "pipe_switch_1" > pipe_switch_1.log
        ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitch.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_switch_2" > pipe_switch_2.log
        ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitch.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_switch_3" > pipe_switch_3.log

         rm -rf pipe_switch_Nonoverlap*
         ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitchNonoverlap.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT}" "pipe_switch_Nonoverlap1" > pipe_switch_Nonoverlap1.log
         ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitchNonoverlap.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_switch_Nonoverlap2" > pipe_switch_Nonoverlap2.log
         ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitchNonoverlap.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_switch_Nonoverlap3" > pipe_switch_Nonoverlap3.log

         rm -rf pipe_switch_aslr*
         echo 2 > /proc/sys/kernel/randomize_va_space
        ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitch.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT}" "pipe_switch_aslr1" > pipe_switch_aslr1.log
        ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitch.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_switch_aslr2" > pipe_switch_aslr2.log
        ./runAllFalkor_counters_instr_v12.sh "CPU,L2" "-C 1 $dir/measureSwitch.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT}" "pipe_switch_aslr3" > pipe_switch_aslr3.log
         echo 0 > /proc/sys/kernel/randomize_va_space
    else
        if [[ ${TEST} == *"pipe2p"* ]]; then
            #Collecting perf stat
            rm -rf single.score single.stat
            perf stat -e instructions,cycles,cs -o single.stat --append $dir/measureSingle.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT} >single.score
            echo ""
            perf stat -e instructions,cycles,cs -o single.stat --append $dir/measureSingle.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT} >>single.score
            echo ""
            perf stat -e instructions,cycles,cs -o single.stat --append $dir/measureSingle.${TARGET}.elf -n 4096 -s 8 -l ${LOOP} -r ${REPEAT} >>single.score
            echo ""
            perf stat -e instructions,cycles,cs -o single.stat --append $dir/measureSingle.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT} >>single.score
            echo ""
            perf stat -e instructions,cycles,cs -o single.stat --append $dir/measureSingle.${TARGET}.elf -n 16384 -s 8 -l ${LOOP} -r ${REPEAT} >>single.score
            echo ""
            perf stat -e instructions,cycles,cs -o single.stat --append $dir/measureSingle.${TARGET}.elf -n 32768 -s 8 -l ${LOOP} -r ${REPEAT} >>single.score

            rm -rf switch.score switch.stat
            perf stat -e instructions,cycles,cs -o switch.stat --append $dir/measureSwitch.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT} >switch.score
            echo ""
            perf stat -e instructions,cycles,cs -o switch.stat --append $dir/measureSwitch.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT} >>switch.score
            echo ""
            perf stat -e instructions,cycles,cs -o switch.stat --append $dir/measureSwitch.${TARGET}.elf -n 4096 -s 8 -l ${LOOP} -r ${REPEAT} >>switch.score
            echo ""
            perf stat -e instructions,cycles,cs -o switch.stat --append $dir/measureSwitch.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT} >>switch.score
            echo ""
            perf stat -e instructions,cycles,cs -o switch.stat --append $dir/measureSwitch.${TARGET}.elf -n 16384 -s 8 -l ${LOOP} -r ${REPEAT} >>switch.score
            echo ""
            perf stat -e instructions,cycles,cs -o switch.stat --append $dir/measureSwitch.${TARGET}.elf -n 32768 -s 8 -l ${LOOP} -r ${REPEAT} >>switch.score

            rm -rf switchNonoverlap.score switchNonoverlap.stat
            perf stat -e instructions,cycles,cs -o switchNonoverlap.stat --append $dir/measureSwitchNonoverlap.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT} >switchNonoverlap.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchNonoverlap.stat --append $dir/measureSwitchNonoverlap.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT} >>switchNonoverlap.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchNonoverlap.stat --append $dir/measureSwitchNonoverlap.${TARGET}.elf -n 4096 -s 8 -l ${LOOP} -r ${REPEAT} >>switchNonoverlap.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchNonoverlap.stat --append $dir/measureSwitchNonoverlap.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT} >>switchNonoverlap.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchNonoverlap.stat --append $dir/measureSwitchNonoverlap.${TARGET}.elf -n 16384 -s 8 -l ${LOOP} -r ${REPEAT} >>switchNonoverlap.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchNonoverlap.stat --append $dir/measureSwitchNonoverlap.${TARGET}.elf -n 32768 -s 8 -l ${LOOP} -r ${REPEAT} >>switchNonoverlap.score
        elif [[ ${TEST} == *"fifo2p"* ]]; then
            #Collecting perf stat
            rm -rf singleFIFO.score singleFIFO.stat
            perf stat -e instructions,cycles,cs -o singleFIFO.stat --append $dir/measureSingleFIFO.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT} >singleFIFO.score
            echo
            perf stat -e instructions,cycles,cs -o singleFIFO.stat --append $dir/measureSingleFIFO.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT} >>singleFIFO.score
            echo ""
            perf stat -e instructions,cycles,cs -o singleFIFO.stat --append $dir/measureSingleFIFO.${TARGET}.elf -n 4096 -s 8 -l ${LOOP} -r ${REPEAT} >>singleFIFO.score
            echo ""
            perf stat -e instructions,cycles,cs -o singleFIFO.stat --append $dir/measureSingleFIFO.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT} >>singleFIFO.score

            rm -rf switchFIFO.score switchFIFO.stat
            perf stat -e instructions,cycles,cs -o switchFIFO.stat --append $dir/measureSwitchFIFO.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT} >switchFIFO.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchFIFO.stat --append $dir/measureSwitchFIFO.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT} >>switchFIFO.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchFIFO.stat --append $dir/measureSwitchFIFO.${TARGET}.elf -n 4096 -s 8 -l ${LOOP} -r ${REPEAT} >>switchFIFO.score
            echo ""
            perf stat -e instructions,cycles,cs -o switchFIFO.stat --append $dir/measureSwitchFIFO.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT} >>switchFIFO.score
        elif [[ ${TEST} == *"fifo2e"* ]]; then
            #Collecting perf stat
            rm -rf switchExe2.score switchExe2.stat testExe1.stat testExe1.score
            perf stat -e instructions,cycles,cs -o testExe1.stat --append  $dir/measureExe1FIFO.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT} > testExe1.score&
            perf stat -e instructions,cycles,cs -o switchExe2.stat --append $dir/measureExe2FIFO.${TARGET}.elf -n 0 -s 0 -l ${LOOP} -r ${REPEAT} >switchExe2.score
            echo ""

            perf stat -e instructions,cycles,cs -o testExe1.stat --append $dir/measureExe1FIFO.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT} >> testExe1.score&
            perf stat -e instructions,cycles,cs -o switchExe2.stat --append $dir/measureExe2FIFO.${TARGET}.elf -n 1024 -s 8 -l ${LOOP} -r ${REPEAT} >>switchExe2.score
            echo ""

            perf stat -e instructions,cycles,cs -o testExe1.stat --append $dir/measureExe1FIFO.${TARGET}.elf -n 4096 -s 8 -l ${LOOP} -r ${REPEAT} >> testExe1.score&
            perf stat -e instructions,cycles,cs -o switchExe2.stat --append $dir/measureExe2FIFO.${TARGET}.elf -n 4096 -s 8 -l ${LOOP} -r ${REPEAT} >>switchExe2.score
            echo ""

            perf stat -e instructions,cycles,cs -o testExe1.stat --append $dir/measureExe1FIFO.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT} >> testExe1.score &
            perf stat -e instructions,cycles,cs -o switchExe2.stat --append $dir/measureExe2FIFO.${TARGET}.elf -n 8192 -s 8 -l ${LOOP} -r ${REPEAT} >>switchExe2.score
        fi

        #####Parsing and reporting scores###########
        if [[ ${TEST} == *"pipe2p"* ]]; then
            echo "pipe1p score"
            grep  "array_size" single.score | grep -Eo '[0-9]+(, stride)' | grep -Eo '[0-9]*'
            grep  "avg time1" single.score | grep -Eo '[0-9]*\.[0-9]*$'

            echo "perf pipe1p"
            grep  "instructions" single.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
            grep  "cycles" single.stat | grep -Eo '[0-9,]*'
            grep  "seconds time elapsed" single.stat | grep -Eo '[0-9]*\.[0-9]*'
            grep  "cs" single.stat | grep -Eo '[0-9,]*'

            echo "pipe2p score"
            grep  "array_size" switch.score | grep -Eo '[0-9]+(, stride)' | grep -Eo '[0-9]*'
            grep  "avg time2" switch.score | grep -Eo '[0-9]*\.[0-9]*$'

            echo "pipe2p switch"
            grep  "instructions" switch.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
            grep  "cycles" switch.stat | grep -Eo '[0-9,]*'
            grep  "seconds time elapsed" switch.stat | grep -Eo '[0-9]*\.[0-9]*'
            grep  "cs" switch.stat | grep -Eo '[0-9,]*'

            echo "pipe2p nonoverlap score"
            grep  "array_size" switchNonoverlap.score | grep -Eo '[0-9]+(, stride)' | grep -Eo '[0-9]*'
            grep  "avg time2" switchNonoverlap.score | grep -Eo '[0-9]*\.[0-9]*$'

            echo "perf pipe2p nonoverlap"
            grep  "instructions" switchNonoverlap.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
            grep  "cycles" switchNonoverlap.stat | grep -Eo '[0-9,]*'
            grep  "seconds time elapsed" switchNonoverlap.stat | grep -Eo '[0-9]*\.[0-9]*'
            grep  "cs" switchNonoverlap.stat | grep -Eo '[0-9,]*'
        elif [[ ${TEST} == *"fifo2p"* ]]; then
            echo "FIFO1p score"
            grep  "array_size" singleFIFO.score | grep -Eo '[0-9]+(, stride)' | grep -Eo '[0-9]*'
            grep  "avg time1" singleFIFO.score | grep -Eo '[0-9]*\.[0-9]*$'

            echo "perf FIFO1p"
            grep  "instructions" singleFIFO.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
            grep  "cycles" singleFIFO.stat | grep -Eo '[0-9,]*'
            grep  "seconds time elapsed" singleFIFO.stat | grep -Eo '[0-9]*\.[0-9]*'
            grep  "cs" singleFIFO.stat | grep -Eo '[0-9,]*'

            echo "FIFO2p score"
            grep  "array_size" switchFIFO.score | grep -Eo '[0-9]+(, stride)' | grep -Eo '[0-9]*'
            grep  "avg time2" switchFIFO.score | grep -Eo '[0-9]*\.[0-9]*$'

            echo "perf FIFO2p"
            grep  "instructions" switchFIFO.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
            grep  "cycles" switchFIFO.stat | grep -Eo '[0-9,]*'
            grep  "seconds time elapsed" switchFIFO.stat | grep -Eo '[0-9]*\.[0-9]*'
            grep  "cs" switchFIFO.stat | grep -Eo '[0-9,]*'
        elif [[ ${TEST} == *"fifo2e"* ]]; then
            echo "Exe2FIFO score"
            grep  "array_size" switchExe2.score | grep -Eo '[0-9]+(, stride)' | grep -Eo '[0-9]*'
            grep  "avg time2" switchExe2.score | grep -Eo '[0-9]*\.[0-9]*$'

            echo "Exe2FIFO perf"
            grep  "instructions" switchExe2.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
            grep  "cycles" switchExe2.stat | grep -Eo '[0-9,]*'
            grep  "seconds time elapsed" switchExe2.stat | grep -Eo '[0-9]*\.[0-9]*'
            grep  "cs" switchExe2.stat | grep -Eo '[0-9,]*'

            echo "Exe1FIFO score for testing"
            grep  "array_size" testExe1.score | grep -Eo '[0-9]+(, stride)' | grep -Eo '[0-9]*'
            grep  "avg time2" testExe1.score | grep -Eo '[0-9]*\.[0-9]*$'

            echo "Exe1FIFO perf for testing"
            grep  "instructions" testExe1.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
            grep  "cycles" testExe1.stat | grep -Eo '[0-9,]*'
            grep  "seconds time elapsed" testExe1.stat | grep -Eo '[0-9]*\.[0-9]*'
            grep  "cs" testExe1.stat | grep -Eo '[0-9,]*'
        fi
    fi
fi
