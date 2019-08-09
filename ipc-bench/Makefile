ifeq ($(ARCH),aarch64)
    base=/prj/dcg/modeling/encnaa/workloads/share/toolchains/gcc-7.1.1-linaro17.08
    CC=${base}/aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc

    CFLAGS  = -static -g -Wall -O3
    LDFLAGS = -static -lrt
else
    base=/usr/bin
    CC=${base}/gcc

    CFLAGS = -static -g -Wall -O3
    LDFLAGS = -lrt
endif

all: pipe_lat pipe_thr \
	unix_lat unix_thr \
	tcp_lat tcp_thr \
	tcp_local_lat tcp_remote_lat \
	udp_lat

.c:
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

run:
	./binaries/pipe_lat.$(ARCH).elf 100 10000 1 1 0
	./binaries/unix_lat.$(ARCH).elf 100 10000 1 1 0
	./binaries/tcp_lat.$(ARCH).elf 100 10000 1 1 0
	./binaries/pipe_self_lat.$(ARCH).elf 100 10000 1 0
	./binaries/unix_self_lat.$(ARCH).elf 100 10000 1 0
	./binaries/tcp_self_lat.$(ARCH).elf 100 10000 1 0
	#./udp_lat 100 10000 1 1 0
	#./pipe_thr 100 10000 1 1 0
	#./unix_thr 100 10000 1 1 0
	#./tcp_thr 100 10000 1 1 0

clean:
	rm -f binaries/*$(ARCH)*elf
