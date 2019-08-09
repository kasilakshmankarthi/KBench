#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

struct arg {
  long a, b;
  const char *p;
  long *rst;
};
typedef struct arg arg;

void* hmr(void *);

int main(int argc, char** argv)
{
  long i;
  long num_threads;
  long accesses_per_thread;
  long result;
  //const char* tmp_path = "/tmp/hhvm-nginxXhubIt/laravel-4.2.0/app/storage/sessions/adee2ed57548a30bea3eab38080bb0c3bd3ffad2";
  const char* tmp_path = "/data/local/tmp/tmphammer";

  if (argc != 3) {
    num_threads = 100;
    accesses_per_thread = 50000;
  }
  else {
    num_threads = atoi(argv[1]);
    accesses_per_thread = atoi(argv[2]);
  }
  printf("accesses=%ld threads=%ld per_thread=%ld\n",
         accesses_per_thread * num_threads, num_threads, accesses_per_thread);

  pthread_t hmr_threads[num_threads];
  long hmrs[num_threads];
  for (i = 0; i < num_threads; ++i) hmrs[i] = 0;

  creat(tmp_path, 0664);
  result = chmod(tmp_path, 0664);
  if (result = -1) printf("chmod failed\n");

  arg args[num_threads];
  for (i = 0; i < num_threads; ++i) {
    args[i].a = 1;
    args[i].b = accesses_per_thread;
    args[i].p = tmp_path;
    args[i].rst = &hmrs[i];
    pthread_create(&hmr_threads[i], NULL, hmr, (void*)(&args[i]));
    //printf("created thread %d with &result = %p\n", i, args[i].rst);
  }
  //printf("created %d hmr threads\n", i);

  for (i = 0; i < num_threads; ++i) {
    result = pthread_join(hmr_threads[i], NULL);
  //  printf("join result = %d\n");
  }

  for (i = 0; i < num_threads; ++i) {
    //printf("%ld ", hmrs[i]);
    result += hmrs[i];
  }

  printf("%ld total access()'s\n", result);
}

void* hmr(void *ptr)
{
  long i, temp = 0;
  arg *x = (arg*)ptr;
  int rval;
  const char *path = x->p;
  struct stat buf;

  for(i = x->a; i <= x->b; ++i) {
    //rval = access(path, F_OK);
    rval = fstatat(AT_FDCWD, path, &buf, AT_SYMLINK_NOFOLLOW);
    if (rval == 0) temp += 1;
  }
  //printf("result %p = %d\n", x->rst, temp);
  *(x->rst) = temp;
}
