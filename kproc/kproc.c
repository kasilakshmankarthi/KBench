/*
 * lat_proc.c - process creation tests
 *
 * Usage: lat_proc [-P <parallelism] [-W <warmup>] [-N <repetitions>] procedure|fork|exec|shell
 *
 * TODO - linux clone, plan9 rfork, IRIX sproc().
 *
 * Copyright (c) 1994 Larry McVoy.  Distributed under the FSF GPL with
 * additional restriction that results may published only if
 * (1) the benchmark is unmodified, and
 * (2) the version in the sccsid below is included in the report.
 * Support for this development by Sun Microsystems is gratefully acknowledged.
 */
#include <signal.h>
#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

char	*id = "$Id$\n";

#ifdef STATIC
#warning "kasi static"
#define	PROG "/tmp/hello-s"
#define STATIC_PREFIX "Static "
#else
#warning "kasi not static"
#define	PROG "/tmp/hello"
#define STATIC_PREFIX ""
#endif

pid_t child_pid;
typedef unsigned long iter_t;
static volatile unsigned long use_result_dummy;

void do_shell(iter_t iterations, void* cookie);
void do_forkexec(iter_t iterations,void* cookie);
void do_fork(iter_t iterations, void* cookie);
void do_procedure(iter_t iterations, void* cookie);

int
handle_scheduler(int childno, int benchproc, int nbenchprocs)
{
        //Default case (do nothing)
        return 0;
}

void
qproc_usage(int argc, char *argv[], char* usage)
{
	fprintf(stderr, stderr,"Usage: %s %s", argv[0], usage);
	exit(-1);
}

void
cleanup(iter_t iterations, void* cookie)
{
	if (iterations) return;

	if (child_pid) {
		kill(child_pid, SIGKILL);
		waitpid(child_pid, NULL, 0);
		child_pid = 0;
	}
}

void
use_int(int result)
{
  use_result_dummy += result;
}

int
main(int ac, char **av)
{
	int parallel = 1;
	int warmup = 0;
	iter_t iterations = -1;
	int c;
	char* usage = "[-W <warmup>] [-N <iterations>] procedure|fork|exec|shell\n";

	while (( c = getopt(ac, av, "P:W:N:")) != EOF) {
		switch(c) {
	        case 'W':
			warmup = atoi(optarg);
			break;
		case 'N':
			iterations = atoi(optarg);
			break;
		default:
			qproc_usage(ac, av, usage);
			break;
		}
	}

	if (optind + 1 != ac) { /* should have one argument left */
		qproc_usage(ac, av, usage);
	}

	if (!strcmp("procedure", av[optind])) {
	        do_procedure(iterations, NULL);
	} else if (!strcmp("fork", av[optind])) {
	        do_fork(iterations, NULL);
  } else if (!strcmp("exec", av[optind])) {
	         do_forkexec(iterations, NULL);
  } else if (!strcmp("shell", av[optind])) {
	        do_shell(iterations, NULL);
	} else {
		qproc_usage(ac, av, usage);
	}
	return(0);
}

void
do_shell(iter_t iterations, void* cookie)
{
	//signal(SIGCHLD, SIG_DFL);
	//handle_scheduler(benchmp_childid(), 0, 1);
	while (iterations-- > 0) {
		switch (child_pid = fork()) {
		case -1:
			perror("fork");
			exit(1);

		case 0:	/* child */
			//handle_scheduler(benchmp_childid(), 1, 1);
			close(1);
			execlp("/bin/sh", "sh", "-c", PROG, 0);
			exit(1);

		default:
			waitpid(child_pid, NULL,0);
		}
		child_pid = 0;
	}
}

void
do_forkexec(iter_t iterations, void* cookie)
{
	char	*nav[2];

	//signal(SIGCHLD, SIG_DFL);
	//handle_scheduler(benchmp_childid(), 0, 1);
	fprintf(stderr, "Value of prog=%s\n", PROG);
	struct timeval start, stop;
  unsigned long delta;
  iter_t iterations_ = iterations;

  gettimeofday(&start, NULL);

	while (iterations-- > 0) {
		nav[0] = PROG;
		nav[1] = 0;
		switch (child_pid = fork()) {
		case -1:
			perror("fork");
			exit(1);

		case 0: 	/* child */
			//handle_scheduler(benchmp_childid(), 1, 1);
#ifdef DEBUG
			int result = execve(PROG, nav, 0);
                        fprintf(stderr, "Value of error=%d\n", result);
			exit(1);
#else
                        close(1);
                        execve(PROG, nav, 0);
                        exit(1);
#endif

		default:
			waitpid(child_pid, NULL,0);
		}
		child_pid = 0;
	}

	gettimeofday(&stop, NULL);

	delta =
        (stop.tv_sec - start.tv_sec) * 1000000000 + (stop.tv_usec - start.tv_usec)*1000;
  fprintf(stderr, "do_forkexec average latency %li ns \n", (delta/iterations_) );
}

void
do_fork(iter_t iterations, void* cookie)
{
  struct timeval start, stop;
  unsigned long delta;
  iter_t iterations_ = iterations;

  gettimeofday(&start, NULL);

	//signal(SIGCHLD, SIG_DFL);
	//handle_scheduler(benchmp_childid(), 0, 1);
	while (iterations-- > 0) {
		switch (child_pid = fork()) {
		case -1:
			perror("fork");
			exit(1);

		case 0:	/* child */
			//handle_scheduler(benchmp_childid(), 1, 1);
			exit(1);

		default:
			waitpid(child_pid, NULL,0);
		}
		child_pid = 0;
	}

	gettimeofday(&stop, NULL);

	delta =
        (stop.tv_sec - start.tv_sec) * 1000000000 + (stop.tv_usec - start.tv_usec)*1000;
  fprintf(stderr, "do_fork average latency %li ns \n", (delta/iterations_));

}

void
do_procedure(iter_t iterations, void* cookie)
{
  struct timeval start, stop;
  unsigned long delta;
  iter_t iterations_ = iterations;

  gettimeofday(&start, NULL);

	int r = 2;
	//handle_scheduler(benchmp_childid(), 0, 1);
	while (iterations-- > 0) {
		use_int(r);
	}

	gettimeofday(&stop, NULL);

	delta =
        (stop.tv_sec - start.tv_sec) * 1000000000 + (stop.tv_usec - start.tv_usec)*1000;
  fprintf(stderr, "do_procedure average latency %li ns \n", (delta/iterations_) );

}
