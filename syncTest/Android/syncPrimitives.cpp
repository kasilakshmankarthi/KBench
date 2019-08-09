#include <cstdlib>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sched.h>
#include <sys/resource.h>
#include <unordered_map>
#include <unistd.h>

#define USEC_PER_SEC 1000000ULL
#if defined(__DEBUG__)
  #define MAX_COUNT 1ULL
  extern void spin_wait (unsigned long wait_iter);
  extern void wait64 (unsigned long *lock, unsigned long val);
  extern void wait32 (uint32_t *lock, uint32_t val);
  extern void prefetch64 (unsigned long *ptr);

  extern unsigned long int fetchadd64_acquire_release (unsigned long *ptr, unsigned long val);
  extern unsigned long fetchadd64_acquire (unsigned long *ptr, unsigned long val);
  extern unsigned long fetchadd64_release (unsigned long *ptr, unsigned long val);
  extern unsigned long fetchadd64 (unsigned long *ptr, unsigned long val);
  extern unsigned long fetchsub64 (unsigned long *ptr, unsigned long val);

  extern unsigned long swap64 (unsigned long *ptr, unsigned long val);
  extern unsigned long cas64 (unsigned long *ptr, unsigned long val, unsigned long exp);
  extern unsigned long cas64_acquire (unsigned long *ptr, unsigned long val, unsigned long exp);
  extern unsigned long cas64_release (unsigned long *ptr, unsigned long val, unsigned long exp);
  extern unsigned long cas64_acquire_release (unsigned long *ptr, unsigned long val, unsigned long exp);
#else
  #include "atomics.h"
  #define MAX_COUNT 1000000ULL //1000000ULL
#endif

//In order for the cas primitives to store the value, the expected value
//should match with the value loaded from memory, which in our case is
//always 0. Fixed using ARR_VAL macro set to 0.
#define ARR_VAL 0

using namespace std;

typedef unsigned long (*FnPtr2)(unsigned long *, unsigned long);
typedef unsigned long (*FnPtr3)(unsigned long *, unsigned long, unsigned long);


// Contains information about benchmark options.
typedef struct {
    int cpu_to_lock;
    int locked_freq;
} command_data_t;

void usage() {
    printf("--------------------------------------------------------------------------------\n");
    printf("Usage:");
    printf("    syncTest.<>.elf [--cpu_to_lock CPU] [--locked_freq FREQ_IN_KHZ]\n\n");
    printf("!!!!!!Lock the desired core to a desired frequency before invoking this benchmark.\n");
    printf(
          "Hint: Set scaling_max_freq=scaling_min_freq=FREQ_IN_KHZ. FREQ_IN_KHZ "
          "can be obtained from scaling_available_freq\n");
    printf("--------------------------------------------------------------------------------\n");
}

int processOptions(int argc, char **argv, command_data_t *cmd_data) {
    // Initialize the command_flags.
    cmd_data->cpu_to_lock = 0;
    cmd_data->locked_freq = 1;
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            int *save_value = NULL;
            if (strcmp(argv[i], "--cpu_to_lock") == 0) {
                save_value = &cmd_data->cpu_to_lock;
        } else if (strcmp(argv[i], "--locked_freq") == 0) {
                save_value = &cmd_data->locked_freq;
            } else {
                printf("Unknown option %s\n", argv[i]);
                return -1;
            }
            if (save_value) {
                // Checking both characters without a strlen() call should be
                // safe since as long as the argument exists, one character will
                // be present (\0). And if the first character is '-', then
                // there will always be a second character (\0 again).
                if (i == argc - 1 ||
                    (argv[i + 1][0] == '-' && !isdigit(argv[i + 1][1]))) {
                    printf("The option %s requires one argument.\n", argv[i]);
                    return -1;
                }
                *save_value = (int)strtol(argv[++i], NULL, 0);
            }
        }
    }
    return 0;
}

int main(int argc, char **argv) {
    command_data_t cmd_data;
    unordered_map<string, FnPtr2> map2arg;
    unordered_map<string, FnPtr3> map3arg;

    srand(MAX_COUNT);

#if defined (USE_LSE)
    map2arg["fetchadd64_acquire_release_LSE"] = fetchadd64_acquire_release;
    map2arg["fetchadd64_acquire_LSE"] = fetchadd64_acquire;
    map2arg["fetchadd64_release_LSE"] = fetchadd64_release;
    map2arg["fetchadd64_LSE"] = fetchadd64;
    map2arg["fetchsub64_LSE"] = fetchsub64;
    map2arg["swap64_LSE"] = swap64;

    map3arg["cas64_LSE"] = cas64;
    map3arg["cas64_acquire_LSE"] = cas64_acquire;
    map3arg["cas64_release_LSE"] = cas64_release;
    map3arg["cas64_acquire_release_LSE"] = cas64_acquire_release;
#else
    map2arg["fetchadd64_acquire_release"] = fetchadd64_acquire_release;
    map2arg["fetchadd64_acquire"] = fetchadd64_acquire;
    map2arg["fetchadd64_release"] = fetchadd64_release;
    map2arg["fetchadd64"] = fetchadd64;
    map2arg["fetchsub64"] = fetchsub64;
    map2arg["swap64"] = swap64;

    map3arg["cas64"] = cas64;
    map3arg["cas64_acquire"] = cas64_acquire;
    map3arg["cas64_release"] = cas64_release;
    map3arg["cas64_acquire_release"] = cas64_acquire_release;
#endif

    if( (argc < 3) || (processOptions(argc, argv, &cmd_data) == -1) ) {
        usage();
        return -1;
    }

    unsigned long count = 0;
    // dummy arr
    unsigned long *parr = new unsigned long[MAX_COUNT]();
    //unsigned long idx = 0;

    float avg_time, avg_cyc_per_iter;
    struct timeval begin_time, end_time, elapsed_time;

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cmd_data.cpu_to_lock, &cpuset);
    if (sched_setaffinity(0, sizeof(cpuset), &cpuset) != 0) {
      perror("sched_setaffinity failed");
      return 1;
    }


    for (auto it=map2arg.begin(); it!=map2arg.end(); ++it)
    {
        memset(parr, ARR_VAL, sizeof(parr)*MAX_COUNT);
        FnPtr2 fn = it->second;

        printf("----------------------------------------------------------------------\n");

        count = 0;
        gettimeofday(&begin_time, NULL);
        while (count < MAX_COUNT) {
          //idx = count;//rand()%MAX_COUNT;
          fn(&parr[count], count);
	      count++;
        }
        gettimeofday(&end_time, NULL);
        timersub(&end_time, &begin_time, &elapsed_time);
        fprintf(stderr, "%s: %llu us\n",
                it->first.c_str(), elapsed_time.tv_sec * USEC_PER_SEC + elapsed_time.tv_usec);
        avg_time = (float) (elapsed_time.tv_sec * USEC_PER_SEC + elapsed_time.tv_usec) / (MAX_COUNT * USEC_PER_SEC);
        if (cmd_data.locked_freq != 0) {
           avg_cyc_per_iter =  (float) (1000. * cmd_data.locked_freq) * avg_time;
           fprintf(stderr, "%s average cycles per iteration: %f \n", it->first.c_str(), avg_cyc_per_iter);
        }

        printf("----------------------------------------------------------------------\n");
    }

    for (auto it=map3arg.begin(); it!=map3arg.end(); ++it)
    {
        memset(parr, ARR_VAL, sizeof(parr)*MAX_COUNT);
        FnPtr3 fn = it->second;

        printf("----------------------------------------------------------------------\n");

        count = 0;
        gettimeofday(&begin_time, NULL);
        while (count < MAX_COUNT) {
          //idx = count;//rand()%MAX_COUNT;
          fn(&parr[count], count, ARR_VAL);
          count++;
        }
        gettimeofday(&end_time, NULL);
        timersub(&end_time, &begin_time, &elapsed_time);
        fprintf(stderr, "%s: %llu us\n",
                it->first.c_str(), elapsed_time.tv_sec * USEC_PER_SEC + elapsed_time.tv_usec);
        avg_time = (float) (elapsed_time.tv_sec * USEC_PER_SEC + elapsed_time.tv_usec) / (MAX_COUNT * USEC_PER_SEC);
        if (cmd_data.locked_freq != 0) {
           avg_cyc_per_iter =  (float) (1000. * cmd_data.locked_freq) * avg_time;
           fprintf(stderr, "%s average cycles per iteration: %f \n", it->first.c_str(), avg_cyc_per_iter);
        }

        printf("----------------------------------------------------------------------\n");
    }

#if !defined (USE_LSE)
    /***********Study wait64 ***********/
    memset(parr, ARR_VAL, sizeof(parr)*MAX_COUNT);
    printf("----------------------------------------------------------------------\n");

    count = 0;
    gettimeofday(&begin_time, NULL);
    while (count < MAX_COUNT) {
      //idx = count;//rand()%MAX_COUNT;
      wait64(&parr[count], ARR_VAL);
      count++;
    }
    gettimeofday(&end_time, NULL);
    timersub(&end_time, &begin_time, &elapsed_time);
    fprintf(stderr, "%s: %llu us\n",
            "wait64", elapsed_time.tv_sec * USEC_PER_SEC + elapsed_time.tv_usec);
    avg_time = (float) (elapsed_time.tv_sec * USEC_PER_SEC + elapsed_time.tv_usec) / (MAX_COUNT * USEC_PER_SEC);
    if (cmd_data.locked_freq != 0) {
       avg_cyc_per_iter =  (float) (1000. * cmd_data.locked_freq) * avg_time;
       fprintf(stderr, "%s average cycles per iteration: %f \n", "wait64", avg_cyc_per_iter);
    }
    printf("----------------------------------------------------------------------\n");
    /***********************************/
#endif

    delete[] parr;

    return 0;
}
