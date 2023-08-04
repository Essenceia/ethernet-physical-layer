#include <inttypes.h>
#include <stdio.h>
#include <byteswap.h>

#define I1 57
#define I0 38

int main(){
	uint64_t reg  = UINT64_MAX;
	uint64_t test = 0x1e;
	uint64_t res  = 0;
	uint64_t t  = 0;
	uint64_t i57, i38, ti0;
	printf("in: %016lx\nstate: %016lx\n", test, reg);	
	for( int i=0; i<64; i++){
		i57 = ( reg >> I1 ) & 0x01;
		i38 = ( reg >> I0 ) & 0x01;
		ti0 = ( test >> i)  & 0x01;
		t = ( i57 ^ i38 ) ^ ti0 ;
		res |= t << i;
		reg = (reg << 1)| t;
	}
	printf("output:%016lx\n",  res);
}
