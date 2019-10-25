# wordcount in Futhark

A [Futhark](https://futhark-lang.org) implementation of `wc` as has
become popular for both [Haskell](https://chrispenner.ca/posts/wc) and
[APL](https://ummaycoc.github.io/wc.apl/).  Mostly to demonstrate how
to interact with Futhark from C.

Running `make` produces two executables: `wc-c` which contains Futhark
compiled to sequential code, and `wc-opencl`, which uses parallel
OpenCL code.
