OS=$(shell uname -s)
ifeq ($(OS),Darwin)
OPENCL_LDFLAGS?=-framework OpenCL
else
OPENCL_LDFLAGS?=-lOpenCL
endif

all: wc-c wc-opencl huge.txt

libwc-opencl.c libwc-opencl.h: libwc.fut
	futhark opencl --library libwc.fut -o libwc-opencl

libwc-c.c libwc-c.h: libwc.fut
	futhark c --library libwc.fut -o libwc-c

wc-c: wc.c libwc-c.c libwc-c.h
	gcc wc.c libwc-c.c -o wc-c -O3 -lm

wc-opencl: wc.c libwc-opencl.c libwc-opencl.h
	gcc wc.c libwc-opencl.c -o wc-opencl -O3 -lm $(OPENCL_LDFLAGS) -DOPENCL

huge.txt: big.txt
	cat big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt big.txt > huge.txt

.PHONY: clean

clean:
	rm -f wc-* libwc-*.c libwc-*.h huge.txt
