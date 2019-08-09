ifeq ($(ARCH),aarch64)
    base=/prj/dcg/modeling/encnaa/workloads/share/toolchains/gcc-7.1.1-linaro17.08
    CC=${base}/aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc

    CCFLAGS  = -static -g -Wall
    LDFLAGS =
else
    base=/usr/bin
    CC=${base}/gcc

    CCFLAGS = -static -g -Wall
    LDFLAGS =
endif

ifeq (${DTYPE},double)
  CCFLAGS  += -DTDOUBLE
else
  CCFLAGS += -DTU64
endif

SRC = measureSingle.c measureSwitch.c measureSwitchNonoverlap \
      measureSingleFIFO.c \
      measureExe1FIFO.c measureExe2FIFO.c \
      measureSwitchFIFO.c
OBJ = $(addsuffix .o, $(basename $(SRC)))
TARGET = $(basename $(OBJ))

all: $(TARGET)

measureSingle: measureSingle.o util.o
	${CC} ${CCFLAGS} -o $@ measureSingle.o util.o
	mv measureSingle measureSingle.${ARCH}.elf

measureSwitch: measureSwitch.o util.o
	${CC} ${CCFLAGS} -o $@ measureSwitch.o util.o
	mv measureSwitch measureSwitch.${ARCH}.elf

measureSwitchNonoverlap: measureSwitchNonoverlap.o util.o
	${CC} ${CCFLAGS} -o $@ measureSwitchNonoverlap.o util.o
	mv measureSwitchNonoverlap measureSwitchNonoverlap.${ARCH}.elf

measureSingleFIFO: measureSingleFIFO.o util.o
	${CC} ${CCFLAGS} -o $@ measureSingleFIFO.o util.o
	mv measureSingleFIFO measureSingleFIFO.${ARCH}.elf

measureExe1FIFO: measureExe1FIFO.o util.o
	${CC} ${CCFLAGS} -o $@ measureExe1FIFO.o util.o
	mv measureExe1FIFO measureExe1FIFO.${ARCH}.elf

measureExe2FIFO: measureExe2FIFO.o util.o
	${CC} ${CCFLAGS} -o $@ measureExe2FIFO.o util.o
	mv measureExe2FIFO measureExe2FIFO.${ARCH}.elf

measureSwitchFIFO: measureSwitchFIFO.o util.o
	${CC} ${CCFLAGS} -o $@ measureSwitchFIFO.o util.o
	mv measureSwitchFIFO measureSwitchFIFO.${ARCH}.elf

util.o: util.c util.h
	${CC} ${CCFLAGS} -c $< $(LDFLAGS)

.c.o:
	${CC} ${CCFLAGS} -c $< $(LDFLAGS)

clean:
	rm -f *.o $(TARGET)

