TARGET=$1
echo "Target chosen: " ${TARGET}

DTYPE=$2
echo "Data Type (double/uint64) chosen: " ${DTYPE}

if [[ ${DTYPE} == "uint64" ]]; then
  ./run_csr_fpga.sh ${TARGET} pipe2pi 10000 3
  ./run_csr_fpga.sh ${TARGET} fifo2pi 10000 3
  ./run_csr_fpga.sh ${TARGET} fifo2ei 10000 3
else
  ./run_csr_fpga.sh ${TARGET} pipe2pd 10000 3
  ./run_csr_fpga.sh ${TARGET} fifo2pd 10000 3
  ./run_csr_fpga.sh ${TARGET} fifo2ed 10000 3
fi
