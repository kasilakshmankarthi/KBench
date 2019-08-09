/*
 * FILE: util.h
 * DESCRIPTION: Header file for util.c
 */

#include <inttypes.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>

#define N               3
#define COUNT_R_W_CS    10000
#define MILLION         1000000 /*To convert to microsec*/
#define LARGE           100000000
#define FLUSHSIZE       4194304
#define MULTIPROCESSOR

//FIFO related
#define MSG_LENGTH  1
#define QDT_PIPE_SZ 4096
#define F1     "/tmp/f1"
#define F2     "/tmp/f2"
#define errExit(msg)

#ifdef DTDOUBLE
#define QDT_DT double
#else
#define QDT_DT uint64_t
#endif

#define QDT
#ifdef QDT
    struct timespec gettimeQDT();
    double difftimeQDT(struct timespec end, struct timespec start);

#else
    typedef long long hrtime_t;

    /* get the elapsed time (in seconds) since startup */
    double gethrtime_x86(void);

    /* get the number of CPU cycles since startup */
    hrtime_t gethrcycle_x86(void);

    /* get the number of CPU cycles per microsecond - from Linux /proc filesystem */
    double getMHZ_x86(void);
#endif

/* dump a chunk of memory to /dev/null */
void memdump(QDT_DT *m, int bytes);

/* flush the cache */
void flushCache();

