#include "64b66b.h"
#include "defs.h"

uint64_t scramble(uint64_t *state, uint64_t data, size_t len)
{
	uint64_t g, res;
	res = 0;
	// G_0 = 1 ^ X_38 ^ X_58
	info("scrambler state %016lx\n", *state);
	for(size_t i= 0; i < len; i++){
		g = (( data >> i) & 0x01 )   ^ (( *state >> I0_64b66b) & 0x01 ) ^ (( *state >> I1_64b66b) & 0x01 ); 
		*state = ( *state << 1 ) | ( g & 0x01 );
		res = res | ( (g & 0x01) << i ); 
	}
	return res;
	
}

uint64_t descramble(uint64_t *state, uint64_t data, size_t len)
{
	// TODO
	return 0;
}

