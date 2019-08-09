#!/bin/bash

ARCH=$1
echo "ARCH chosen": $ARCH

rm -rf syncTest.${ARCH}.elf

if [[ "${ARCH}" == "a64-lse" ]]; then
  CFLAGS='-O3 -std=c++11 --static -fno-zero-initialized-in-bss -fPIC -march=armv8.1-a+crc+lse -DUSE_LSE -D__aarch64__'
  /sarc/lab/users/a.iley/cross-gcc/usr/aarch64-unknown-linux-gnueabi/bin/aarch64-unknown-linux-gnueabi-g++ ${CFLAGS} syncPrimitives.cpp -o syncTest
  mv syncTest binaries/syncTest.${ARCH}.elf

  CFLAGS='-O3 -std=c++11 --static -fno-zero-initialized-in-bss -fPIC -march=armv8.1-a+crc+lse -DUSE_LSE -D__aarch64__ -DPREFETCH'
  /sarc/lab/users/a.iley/cross-gcc/usr/aarch64-unknown-linux-gnueabi/bin/aarch64-unknown-linux-gnueabi-g++ ${CFLAGS} syncPrimitives.cpp -o syncTest
  mv syncTest binaries/syncTest.prfm.${ARCH}.elf
elif [[ "${ARCH}" == "a64" ]]; then
  CFLAGS='-O3 -std=c++11 --static -fno-zero-initialized-in-bss -fPIC -D__aarch64__'
  /sarc/lab/users/a.iley/cross-gcc/usr/aarch64-unknown-linux-gnueabi/bin/aarch64-unknown-linux-gnueabi-g++ ${CFLAGS} syncPrimitives.cpp -o syncTest
  mv syncTest binaries/syncTest.${ARCH}.elf

  CFLAGS='-O3 -std=c++11 --static -fno-zero-initialized-in-bss -fPIC -D__aarch64__ -DPREFETCH'
  /sarc/lab/users/a.iley/cross-gcc/usr/aarch64-unknown-linux-gnueabi/bin/aarch64-unknown-linux-gnueabi-g++ ${CFLAGS} syncPrimitives.cpp -o syncTest
  mv syncTest binaries/syncTest.prfm.${ARCH}.elf
else
  CFLAGS='-O3 -std=c++11 --static -ggdb -fno-zero-initialized-in-bss -fPIC -D__x86_64__'
  /sarc/spa/tools/conda/envs/spa-3/bin/g++ ${CFLAGS} syncPrimitives.cpp -o syncTest
  mv syncTest binaries/syncTest.${ARCH}.elf

  CFLAGS='-O3 -std=c++11 --static -ggdb -fno-zero-initialized-in-bss -fPIC -D__x86_64__ -D__DEBUG__'
  /sarc/spa/tools/conda/envs/spa-3/bin/g++ ${CFLAGS} syncPrimitives.cpp atomics_gdb.cpp -o syncTest
  mv syncTest binaries/syncTest.${ARCH}.dbg.elf
fi
