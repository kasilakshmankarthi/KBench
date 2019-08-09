CPU=$1
echo "CPU chosen: " ${CPU}

if [[ ${CPU} == "skylake" ]]; then
   TARGET=x86_64
else
   TARGET=aarch64
fi

#perf record ./measureSwitchFIFO.${TARGET}.elf -n 0 -s 0 -l 10000 -r 3
#perf report > ${CPU}_switchFIFO_no_so.report
#perf annotate --vmlinux vmlinux > ${CPU}_switchFIFO_no_so.annot


#./measureExe1FIFO.${TARGET}.elf -n 0 -s 0 -l 10000 -r 3&
#perf record ./measureExe2FIFO.${TARGET}.elf -n 0 -s 0 -l 10000 -r 3
#perf report > ${CPU}_switchExe2FIFO_no_so.report
#perf annotate --vmlinux vmlinux > ${CPU}_switchExe2FIFO_no_so.annot

perf record ./measureSwitch.${TARGET}.elf -n 1024 -s 8 -l 10000 -r 3
perf report > ${CPU}_switch_n1k_s8.report
perf annotate --vmlinux vmlinux > ${CPU}_switch_n1k_s8.annot
