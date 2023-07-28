#ifndef TV_H
#define TV_H

#include <stdio.h>

typedef struct{
	// tx channel
	// fifo 
	// next packet to send
	// idle count down
}tv_t;

tv_t * tv_alloc(const char * path);

void tv_create_packet(tv_t * t,size_t itch_n);

uint64_t tv_pcs_get_next_drivers(tv_t* t, uint8_t *mask, uint8_t *last);

void tv_free(tv_t * t);
#endif // TV_H
