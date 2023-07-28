#ifndef DEFS_H
#define DEFS_H

#ifdef DEBUG
#define info(...) printf(__VA_ARGS__)
#else
#define info(...)
#endif

#endif
