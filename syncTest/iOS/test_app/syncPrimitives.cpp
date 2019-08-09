#include <cstdlib>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <sys/time.h>
#include <sched.h>
#include <sys/resource.h>
#include <unordered_map>
#include <unistd.h>

#include "syncPrimitives.h"
#include "atomics.h"

#define USEC_PER_SEC 1000000ULL
#define MAX_COUNT 1000000ULL //1000000000ULL
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

int runSyncPrimitives(void) {
    command_data_t cmd_data;
    cmd_data.locked_freq = 2500000; //2.5GHz
    unordered_map<std::string, FnPtr2> map2arg;
    unordered_map<std::string, FnPtr3> map3arg;

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

    unsigned long count = 0;
    // dummy arr
    unsigned long *parr = new unsigned long[MAX_COUNT]();
    //unsigned long idx = 0;

    float avg_time, avg_cyc_per_iter;
    struct timeval begin_time, end_time, elapsed_time;

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
