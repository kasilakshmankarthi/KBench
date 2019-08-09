#!/bin/bash
make -f Makefile clean
make -B -f Makefile ARCH=x86_64 DTTYPE=double
mv *elf bin/double

make -f Makefile clean
make -B -f Makefile ARCH=x86_64 DTTYPE=uint64
mv *elf bin/uint64

make -f Makefile clean
make -B -f Makefile ARCH=aarch64 DTYPE=double
mv *elf bin/double

make -f Makefile clean
make -B -f Makefile ARCH=aarch64 DTTYPE=uint64
mv *elf bin/uint64

make -f Makefile clean
