#!/bin/bash

TARGET=$1
OPERATION=$2

echo "Target chosen:" ${TARGET}
echo "Operation:" ${OPERATION}

if [[ ${OPERATION} == "build" ]]; then
    make -f Makefile ARCH=${TARGET}

    mv pipe_lat       binaries/pipe_lat.${TARGET}.elf
    mv pipe_thr       binaries/pipe_thr.${TARGET}.elf
    mv unix_lat       binaries/unix_lat.${TARGET}.elf
    mv unix_thr       binaries/unix_thr.${TARGET}.elf
    mv tcp_lat        binaries/tcp_lat.${TARGET}.elf
    mv tcp_thr        binaries/tcp_thr.${TARGET}.elf
    mv tcp_local_lat  binaries/tcp_local_lat.${TARGET}.elf
    mv tcp_remote_lat binaries/tcp_remote_lat.${TARGET}.elf
    mv udp_lat        binaries/udp_lat.${TARGET}.elf
fi

if [[ ${OPERATION} == "run" ]]; then
    make v=1 ARCH=${TARGET} run
fi
