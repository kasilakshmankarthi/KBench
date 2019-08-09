ifeq ($(ARCH),aarch64)
    CC = /work/kasilka/bin/ndk21-arm64/bin/aarch64-linux-android-gcc

    CFLAGS  = -static -g -Wall -O3
    LDFLAGS = -static
else
    CC = /usr/bin/gcc

    CFLAGS = -static -g -Wall -O3
    LDFLAGS = -static -lpthread
endif

all: tmphammer

.c:
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
	mv tmphammer tmphammer.$(ARCH).elf

clean:
	rm -f tmphammer.$(ARCH).elf
