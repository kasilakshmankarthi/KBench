/*
    Measure latency of IPC using unix domain sockets


    Copyright (c) 2016 Erik Rigtorp <erik@rigtorp.se>

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.
*/

#define _GNU_SOURCE
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#if defined(_POSIX_TIMERS) && (_POSIX_TIMERS > 0) &&                           \
    defined(_POSIX_MONOTONIC_CLOCK)
#define HAS_CLOCK_GETTIME_MONOTONIC
#endif

#define errExit(msg)	do { perror(msg); exit(EXIT_FAILURE); \
							  } while (0)

typedef int bool;
#define false 0
#define true  1

int main(int argc, char *argv[]) {
  
  int64_t iters;
  int64_t count, i, delta;
#ifdef HAS_CLOCK_GETTIME_MONOTONIC
  struct timespec start, stop;
#else
  struct timeval start, stop;
#endif
  cpu_set_t set;
  int parentCPU, childCPU;
  bool isEnableAngelSignals;

  if (argc != 6) {
    printf("usage: ctx_lat <iterations-count> <roundtrip-count> <parent cpu> <child cpu> <Enable(1)/Disable(0) angel signals>\n");
    return 1;
  }

  iters = atoi(argv[1]);
  count = atol(argv[2]);
  parentCPU = atoi(argv[3]);
  childCPU = atoi(argv[4]);
  isEnableAngelSignals = atoi(argv[5]);
  CPU_ZERO(&set);

  printf("iterations count: %li \n", iters);
  printf("roundtrip count: %li\n", count);

  if (!fork()) { /* child */
    CPU_SET(childCPU, &set);

    if (sched_setaffinity(getpid(), sizeof(set), &set) == -1){
     errExit("sched_setaffinity of child failed");
    }

    for (i = 0; i < count; i++) {
        int j;
        int k;
        for (j = 0; j < iters; j++) {
            k = j;
            (void)k;
        }
        sched_yield();
    }
  } else { /* parent */
    CPU_SET(parentCPU, &set);

    if (sched_setaffinity(getpid(), sizeof(set), &set) == -1){
     errExit("sched_setaffinity of parent failed");
    }

#ifdef ANGEL
  if( isEnableAngelSignals )
  {
    intptr_t _arg1 = (intptr_t)SAVE_CHECKPOINT_ARG;
    angel_hypercall(ANGEL_CONTROL_SERVICE, (void *)_arg1);

    intptr_t _arg2 = (intptr_t)BEGIN_BENCHMARK_ARG;
    angel_hypercall(ANGEL_CONTROL_SERVICE, (void *)_arg2);
  }
#endif

#ifdef HAS_CLOCK_GETTIME_MONOTONIC
    if (clock_gettime(CLOCK_MONOTONIC, &start) == -1) {
      perror("clock_gettime");
      return 1;
    }
#else
    if (gettimeofday(&start, NULL) == -1) {
      perror("gettimeofday");
      return 1;
    }
#endif

    for (i = 0; i < count; i++) {
        int j;
        int k;
        for (j = 0; j < iters; j++) {
            k = j;
            (void)k;
        }
        sched_yield();
    }
#ifdef HAS_CLOCK_GETTIME_MONOTONIC
    if (clock_gettime(CLOCK_MONOTONIC, &stop) == -1) {
      perror("clock_gettime");
      return 1;
    }

    delta = ((stop.tv_sec - start.tv_sec) * 1000000000 +
             (stop.tv_nsec - start.tv_nsec));

#else
    if (gettimeofday(&stop, NULL) == -1) {
      perror("gettimeofday");
      return 1;
    }

    delta =
        (stop.tv_sec - start.tv_sec) * 1000000000 + (stop.tv_usec - start.tv_usec) * 1000;

#endif

    printf("average ctx_switch latency: %li ns\n", delta / (count * 2));
#ifdef ANGEL
    if( isEnableAngelSignals )
    {
      intptr_t _arg2 = (intptr_t)END_BENCHMARK_ARG;
      angel_hypercall(ANGEL_CONTROL_SERVICE, (void *)_arg2);
    }
#endif

  }

  return 0;
}

