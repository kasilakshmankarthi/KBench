ifeq ($(ARCH),aarch64)
    CC = /prj/dcg/modeling/encnaa/workloads/share/toolchains/gcc-7.1.1-linaro17.08/aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc

    local_angel=./disk/angel-utils/libangel
    local_angel_include=$(local_angel)/include
    local_angel_lib=$(local_angel)/build

    CFLAGS  = -static -g -Wall -O2
    LDFLAGS = -static -lpthread
else
    CC = /usr/bin/gcc

    CFLAGS = -static -g -Wall -O2
    LDFLAGS = -static -lpthread
endif

all:qproc

.c:
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
	mv qproc qproc.$(ARCH).elf

.PHONY: clean

clean:
	rm -f qproc.$(ARCH).elf
