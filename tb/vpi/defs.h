#ifndef DEFS_H
#define DEFS_H


#ifdef DEBUG
#include <stdio.h>
#define info(...) printf(__VA_ARGS__)
#else
#define info(...)
#endif

#endif
