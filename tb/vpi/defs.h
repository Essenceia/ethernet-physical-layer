/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 
#ifndef DEFS_H
#define DEFS_H


#ifdef DEBUG
#include <stdio.h>
#define info(...) printf(__VA_ARGS__)
#else
#define info(...)
#endif

#endif
