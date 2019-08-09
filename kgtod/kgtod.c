#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

int
main(int ac, char **av)
{
	int sleep_sec = 0;
	char* usage = "[-S <sleep (sec)>]\n";
	int c;

	while (( c = getopt(ac, av, "S:")) != EOF) {
		switch(c) {
	        case 'S':
			sleep_sec = atoi(optarg);
			break;
		default:
			//qgtod_usage(ac, av, usage);
			break;
		}
	}

	//if (optind + 1 != ac) { 
	    /* should have one argument left */
		//qgtod_usage(ac, av, usage);
	//}

  struct timeval start, stop;
  unsigned long delta;
  
  gettimeofday(&start, NULL);
  sleep ( sleep_sec);
  gettimeofday(&stop, NULL);

  delta =
        (stop.tv_sec - start.tv_sec) * 1000000 + (stop.tv_usec - start.tv_usec);
  fprintf(stderr, "gettimeodday() %li us for a sleep of %d\n", delta, sleep_sec );
	
	return(0);
}