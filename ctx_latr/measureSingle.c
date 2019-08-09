/*
 * FILE: measureSingle.c
 * DESCRIPTION: Single process program simulating two processes communications
 * OUTPUT:	time1 = Overhead of traversing through array + pipe overhead
 *
 *              use measureSwitch to get time2
 *              context switch cost = time2 - time1
 */
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <pthread.h>
#include <sys/time.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <sched.h>
#include <errno.h>
#include <linux/unistd.h>
#include "util.h"

void showUsage()
{
  fprintf( stderr, "Usage:\nmeasureSingle <options>\n\
    -n   <number>  size of the array to work on (in byte). default 0.\n\
    -s   <number>  access stride size (in byte). default 0.\n\
    -l   <number>  number of times to perform read/write (or) cs. default 10000. \n\
    -r   <number>  number of times to repeat the test, default 1.\n");
}

void measureSingle(register int array_size, register int stride, register int loop,
	register int *p1, register char *msg, register QDT_DT *f){
    register int i, j, m;

    //printf("\nArray size=%d, stride=%d, and sizeof=%ld\n", array_size, stride, sizeof(QDT_DT));
    for ( i=0; i<loop; i++) {
        for ( m=0; m<stride; m++) {
            for ( j=m; j<array_size; j=j+stride) {
                f[j]++;
            }
        }
        write(p1[1], msg, 1);
        read(p1[0], msg, 1);
    }
}

int main(int argc, char *argv[])
{
    int ret, p1[2], stride=0, array_size=0, repeat = N, loop = COUNT_R_W_CS;
    double time1;
    double tottime = 0;
    QDT_DT *f = NULL;
#ifdef QDT
    struct timespec start_time;
#else
    double start_time;
#endif

    char message;
    int opt;
    short round;
    pid_t p = 0;
    cpu_set_t set;
    CPU_ZERO(&set);

    struct sched_param sp;

#ifdef MULTIPROCESSOR
    CPU_SET(1, &set);
    ret = sched_setaffinity(p, sizeof(set), &set);
    if(ret==-1){
	perror("sched_setaffinity 1 failed");
        exit(1);
    }
    sp.sched_priority = sched_get_priority_max(SCHED_FIFO);
    ret=sched_setscheduler(0, SCHED_FIFO, &sp);
    if(ret==-1){
	perror("sched_setscheduler 1 failed");
        exit(1);
    }
#endif

    while ((opt = getopt(argc, argv, "s:n:l:r:")) != -1) {
        switch (opt) {
            case 'n': /* number of QDT_DT in the array */
                array_size=atoi(optarg);
		array_size=array_size/sizeof(QDT_DT);
                break;
            case 's':
		stride=atoi(optarg);
		stride=stride/sizeof(QDT_DT);
                break;
            case 'l':
		loop=atoi(optarg);
                break;
            case 'r':
		repeat=atoi(optarg);
                break;
            default:
                fprintf(stderr, "Unknown option character.\n");
		showUsage();
                exit(1);
        }
    }
    if (stride > array_size){
        printf("Warning: stride is bigger than array_size. "
               "Sequential access. \n");
    }

    /* simulate the execution of two pipes on one process */
    /* create a pipe */
    if (pipe (p1) < 0) {
        perror ("create a pipe");
        return -1;
    }

    int pipe_sz = fcntl(p1[1], F_GETPIPE_SZ, sizeof(size_t));
    printf("Annon Pipe size = %d\n", pipe_sz);

    printf("time1 without context switch: \t");
    fflush(stdout);

    /* run repeat times */
    for(round=0; round< repeat; round++){
        if(array_size != 0)
        {
            flushCache();
            f = (QDT_DT*) malloc(array_size*sizeof(QDT_DT));
            if (f==NULL) {
                perror("malloc failed");
                exit (1);
            }
            memset((void *)f, 0x00, array_size*sizeof(QDT_DT));
        }
        //sleep(1);
        start_time = gettimeQDT(); //gethrtime_x86();
        measureSingle(array_size, stride, loop, p1, &message, f);
        time1 = difftimeQDT( gettimeQDT(), start_time); //gethrtime_x86() -start_time;
        time1 = time1/loop;
        printf("%f\t", time1);
        tottime += time1;
        fflush(stdout);
        if(array_size != 0)
        {
            //memdump(f, array_size*sizeof(QDT_DT));
            free(f);
        }
        //sleep(1);
    }
    printf("\nmeasureSingle: array_size = %" PRIu64 ", stride = %ld, avg time1 = %.15f\n",
	array_size*sizeof(QDT_DT), stride*sizeof(QDT_DT), (tottime/repeat));
    return 0;
}
