/*
 * FILE: measureSwitch.c
 * DESCRIPTION: Two processes communication via a pipe.
 * OUTPUT:	time2 = Overhead of traversing through array + pipe overhead
 * 		        + context switch overhead
 *
 * 		use measureSingle to get time1
 *		context switch cost = time2 - time1
 *
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
#include <sys/stat.h>
#include <fcntl.h>
#include "util.h"

#define SCALE 2

void showUsage()
{
  fprintf( stderr, "Usage:\nmeasureSwitch <options>\n\
    -n   <number>  size of the array to work on (in byte). default 0.\n\
    -s   <number>  access stride size (in byte). default 0.\n\
    -l   <number>  number of times to perform read/write (or) cs. default 10000. \n\
    -r   <number>  number of times to repeat the test, default 1.\n");
}


void measureSwitch1(register int array_size, register int stride, register int loop,
	register int *p1, register int *p2, register char *msg,
	register QDT_DT *fc_){

    register int i, j, m;
    //printf("\n1: Array size=%d, stride=%d, sizeof=%ld\n", array_size, stride, sizeof(QDT_DT));
    //printf("\nmeasureSwitch1=%p\n", fc_);

    for ( i=0; i<loop; i++) {
        read(p2[0], msg, 1);
        for ( m=0; m<stride; m++) {
            for ( j=m; j<array_size; j=j+stride) {
                //printf("Testing\n");
                fc_[j]++;
            }
        }
        write(p1[1], msg, 1);
    }
}

void measureSwitch2(register int array_size, register int stride, register int loop,
	register int *p1, register int *p2, register char *msg,
	register QDT_DT *fp_){

    register int i, j, m;
    //printf("\n2: Array size=%d, stride=%d, sizeof=%ld\n", array_size, stride, sizeof(QDT_DT));
    //printf("\nmeasureSwitch2=%p\n", fp_);

    for ( i=0; i<loop; i++) {
        for ( m=0; m<stride; m++) {
            for ( j=(m+array_size); j<(SCALE*array_size); j=j+stride) {
                fp_[j]++;
            }
        }
        write(p2[1], msg, 1);
        read(p1[0], msg, 1);
    }

}

int main(int argc, char *argv[])
{
    int ret, p1[2], p2[2], stride=0, array_size=0, repeat= N, loop = COUNT_R_W_CS;
    double  time1;
    double  avg = 0;
    //QDT_DT *fc = NULL;
    //QDT_DT *fp = NULL;
#ifdef QDT
    struct timespec start_time;
#else
    double start_time;
#endif
    char message;
    int opt;
    short round;
    pid_t pid, p = 0;
    cpu_set_t set;
    struct sched_param sp;

    CPU_ZERO(&set);
#ifdef MULTIPROCESSOR
    //Expectation is child process inherit parent process affinity
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
            case 'n': /* number of QDT_DTs in the array */
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
                fprintf(stderr, "Unknown option optaracter.\n");
                showUsage();
                exit(1);
        }
    }
    if (stride > array_size){
        printf("Warning: stride is bigger than array_size. "
               "Sequential access. \n");
    }

    /* create two pipes: p1[0], p2[0] for read; p1[1], p2[1] for write */
    if (pipe (p1) < 0) {
        perror ("create pipe1");
        return -1;
    }
    if (pipe (p2) < 0) {
        perror ("create pipe2");
        return -1;
    }
    /* communicate between two processes */
    printf("time2 with context swith: \t");
    fflush(stdout);

    for(round=0; round<repeat; round++){
	      //flushCache();
        if ((pid = fork()) <0) {
            perror("fork");
            return -1;
        } else if (pid ==0) {
            // child process
            QDT_DT *fc = NULL;
            if(array_size != 0)
            {
                fc = (QDT_DT*) malloc(array_size*SCALE*sizeof(QDT_DT));
                if (fc==NULL) {
                    perror("malloc fails");
                    exit (1);
                }
                memset((void *)fc, 0x00, array_size*sizeof(QDT_DT));

                //printf("\nArray child=%p\n", fc);
            }
            measureSwitch1(array_size, stride, loop, p1, p2, &message, fc);
	          //sleep(1);
	          if(array_size != 0)
            {
                //memdump(fc, array_size*SCALE*sizeof(QDT_DT));
                free(fc);
            }
	          exit(0);
        } else {
            // parent process
            QDT_DT *fp = NULL;
            if(array_size != 0)
            {
                fp = (QDT_DT*) malloc(array_size*SCALE*sizeof(QDT_DT));
                if (fp==NULL) {
                    perror("malloc fails");
                    exit (1);
                }
                memset((void *)fp, 0x00, array_size*sizeof(QDT_DT));

                //printf("\nArray parent=%p\n", fp);
            }
	          //sleep(1);
            start_time = gettimeQDT(); //gethrtime_x86();
            measureSwitch2(array_size, stride, loop, p1, p2, &message, fp);
            time1 = difftimeQDT( gettimeQDT(),  start_time); //gethrtime_x86()-start_time;
            time1 = time1/(2*loop);
            printf("%f\t", time1);
            avg += time1;
            fflush(stdout);
            //waitpid(pid, NULL, 0);
            if(array_size != 0)
            {
                //memdump(f, array_size*SCALE*sizeof(QDT_DT));
                free(fp);
            }
        }
	//sleep(1);
    }
    printf("\nmeasureSwitch: array_size = %" PRIu64 ", stride = %ld, avg time2 = %.15f\n",
	          array_size*sizeof(QDT_DT), stride*sizeof(QDT_DT), (avg/repeat));
    return 0;
}

