ifeq ($(ARCH),aarch64)
    base=/prj/dcg/modeling/encnaa/workloads/share/toolchains/gcc-7.1.1-linaro17.08
    CC=${base}/aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc

    CFLAGS  = -static -g -Wall -O0
    LDFLAGS = -static -lrt
else
    base=/usr/bin
    CC=${base}/gcc

    CFLAGS = -static -g -Wall -O0
    LDFLAGS = -lrt
endif

all: ctx_lat

.c:
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
	mv ctx_lat ctx_lat.${ARCH}.elf

clean:
	rm -f ctx_lat.$(ARCH).elf
