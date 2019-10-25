#define _POSIX_SOURCE // For fileno().

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <assert.h>
#include <sys/time.h>

#ifdef OPENCL
#include "libwc-opencl.h"
#else
#include "libwc-c.h"
#endif

int main(int argc, char** argv) {
  char *filename;
  int timeit = 0;

  if (argc == 2) {
    filename = argv[1];
  } else if (argc == 3 && strcmp(argv[1], "-t") == 0) {
    filename = argv[2];
    timeit = 1;
  } else {
    fprintf(stderr, "Usage: %s [-t] <file>\n", argv[0]);
    return 1;
  }

  static struct timeval t_start, t_end;

  struct futhark_context_config *cfg =
    futhark_context_config_new();

#ifdef OPENCL
  if (getenv("OPENCL_DEVICE") != NULL) {
    futhark_context_config_set_device(cfg, getenv("OPENCL_DEVICE"));
  }
#endif

  struct futhark_context *ctx =
    futhark_context_new(cfg);

  gettimeofday(&t_start, NULL);
  FILE *fp = fopen(filename, "r");
  assert(fp != NULL);

  fseek(fp, 0, SEEK_END);
  size_t n = ftell(fp);
  rewind(fp);

  void *data =
    mmap(NULL, n, PROT_READ, MAP_SHARED, fileno(fp), 0);
  assert(data != MAP_FAILED);

  struct futhark_u8_1d *arr =
    futhark_new_u8_1d(ctx, data, n);
  assert(arr != NULL);

  int chars, words, lines;
  futhark_entry_wc(ctx, &chars, &words, &lines, arr);

  printf("  %d %d %d %s\n", lines, words, chars, filename);

  futhark_free_u8_1d(ctx, arr);
  futhark_context_free(ctx);
  futhark_context_config_free(cfg);

  gettimeofday(&t_end, NULL);

  if (timeit) {
    printf("runtime: %.3fs\n",
           ((t_end.tv_sec*1000000+t_end.tv_usec) -
            (t_start.tv_sec*1000000+t_start.tv_usec)) / 1000000.0);
  }
}
