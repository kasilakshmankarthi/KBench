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

void showUsage()
{
  fprintf( stderr, "Usage:\nmeasureSwitch <options>\n\
    -n   <number>  size of the array to work on (in byte). default 0.\n\
    -s   <number>  access stride size (in byte). default 0.\n\
    -l   <number>  number of times to perform read/write (or) cs. default 10000. \n\
    -r   <number>  number of times to repeat the test, default 1.\n");
}

void measureSwitch1(register int array_size, register int stride, register int loop,
	register int *pf1r, register int *pf2w,
	register char *msg, register QDT_DT *f)
{
    register int i, j, m;

    for (i=0; i<loop; i++) {
        read( (*pf1r), msg, MSG_LENGTH);
        //printf("read1 = %c\n", (*msg) );

        for ( m=0; m<stride; m++) {
            for ( j=m; j<array_size; j=j+stride) {
                //printf("Testing \n");
                f[j]++;
            }
        }
        write( (*pf2w), msg, MSG_LENGTH);
        //printf("write2 = %c\n", (*msg) );
    }
}

void measureSwitch2(register int array_size, register int stride, register int loop,
	register int *pf1w, register int *pf2r,
        register char *msg, register QDT_DT *f)
{
    register int i, j, m;

    for (i=0; i<loop; i++) {
        for ( m=0; m<stride; m++) {
            for ( j=m; j<array_size; j=j+stride) {
                //printf("Testing \n");
                f[j]++;
            }
        }
        //printf("write1 = %c\n", (*msg) );
        write( (*pf1w), msg, MSG_LENGTH);
        read( (*pf2r), msg, MSG_LENGTH);
        //printf("read2 = %c\n", (*msg) );
    }
}


int main(int argc, char *argv[])
{
    int ret, f1rfd, f1wfd, f2rfd, f2wfd, stride=0, array_size=0, repeat= N, loop = COUNT_R_W_CS;
    double  time1;
    double  tottime = 0;
    QDT_DT *f = NULL;
#ifdef QDT
    struct timespec start_time;
#else
    double start_time;
#endif

    pid_t pid = 0;
    cpu_set_t set;
    struct sched_param sp;

    CPU_ZERO(&set);
#ifdef MULTIPROCESSOR
    //Expectation is child process inherit parent process affinity
    CPU_SET(1, &set);
    ret = sched_setaffinity(pid, sizeof(set), &set);
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
    int opt;
    short round;

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

    // Creating the named file(FIFO)
    mkfifo(F1, 0666);
    mkfifo(F2, 0666);

    char message[MSG_LENGTH];
    memset( message, 'p', sizeof(char)*MSG_LENGTH);

    printf("measureSwitchFIFO (time2 with context swith:) \n");
    fflush(stdout);

    for(round=0; round<repeat; round++){
	//flushCache();
        if ((pid = fork()) <0) {
            perror("fork");
            return -1;
        } else if (pid ==0) {
            //child process
            f1rfd = open(F1, O_RDONLY);
            f2wfd = open(F2, O_WRONLY);

            if (array_size != 0)
            {
                flushCache();
                f = (QDT_DT*) malloc(array_size*sizeof(QDT_DT));
                if (f==NULL) {
                    perror("malloc fails");
                    exit (1);
                }
                memset((void *)f, 0x29, array_size*sizeof(QDT_DT));
            }
            measureSwitch1(array_size, stride, loop, &f1rfd, &f2wfd, message, f);
	    //sleep(1);
	    if (array_size != 0)
            {
                //memdump(f, sizeof(QDT_DT)*array_size);
                free(f);
            }
            close(f1rfd);
            close(f2wfd);

            exit(0);
        } else {
            //parent process
            f1wfd = open(F1, O_WRONLY);
            f2rfd = open(F2, O_RDONLY);

            if (array_size != 0)
            {
                flushCache();
                f = (QDT_DT*) malloc(array_size*sizeof(QDT_DT));
                if (f==NULL) {
                    perror("malloc fails");
                    exit (1);
                }
                memset((void *)f, 0x29, array_size*sizeof(QDT_DT));
            }
	    //sleep(1);
            start_time = gettimeQDT(); //gethrtime_x86();
            measureSwitch2(array_size, stride, loop, &f1wfd, &f2rfd, message, f);
            time1 = difftimeQDT( gettimeQDT(),  start_time); //gethrtime_x86()-start_time;
	    time1 = time1/(2*loop);
            tottime += time1;
            printf("iter=%u, time=%f, tottime=%f\n", round, time1, tottime);
            fflush(stdout);
            //waitpid(pid, NULL, 0);
            if (array_size != 0)
            {
                //memdump(f, sizeof(QDT_DT)*array_size);
                free(f);
            }
            close(f1wfd);
            close(f2rfd);
        }
	//sleep(1);
    }

    printf("\nmeasureSwitchFIFO: array_size = %" PRIu64 ", stride = %ld, avg time2 = %.15f\n",
	            array_size*sizeof(QDT_DT), stride*sizeof(QDT_DT), (tottime/repeat));

    return 0;
}

