#include "pcs_marker.h"
#include <string.h>
#include "defs.h"
/* See ieee 802.3 clause 82.4
 *
 * Table 82–4—BIP 3 bit assignments
* BIP_3 bit number    Assigned 66-bit word bits
*        0            2, 10, 18, 26, 34, 42, 50, 58
*        1            3, 11, 19, 27, 35, 43, 51, 59
*        2            4, 12, 20, 28, 36, 44, 52, 60
*        3            0, 5, 13, 21, 29, 37, 45, 53, 61
*        4            1, 6, 14, 22, 30, 38, 46, 54, 62
*        5            7, 15, 23, 31, 39, 47, 55, 63
*        6            8, 16, 24, 32, 40, 48, 56, 64
*        7            9, 17, 25, 33, 41, 49, 57, 65
*/

#define BVAL(i) (uint8_t)( i < 2 ? (( head >> i ) & 1u) : ( data >> (i-2) & 1u ))
#define BIP(x,i) (uint8_t) (x & (0x1<<i))
#define BIPN(x,i) (uint8_t) (x & ~(0x1<<i))
/* Calculate new bip value
 * head has index [1:0]
 * data          [63:0] */
uint8_t calculate_bip_per_lane(
	uint8_t bip, 
	const block_s out)
{
	uint64_t data = out.data;
	uint8_t  head = out.head;

	#ifdef DEBUG
	uint8_t i = 0;
	#endif

	info("calculate bip per lane , data , head { %lx, %x }\n", data, head );
	// 0
	uint8_t r = BIP(bip,0) ^ ( BVAL(2)  ^ BVAL(10) ^ BVAL(18) ^ BVAL(26) ^ BVAL(34) ^ BVAL(42) ^ BVAL(50) ^ BVAL(58));	
	bip = BIPN(bip,0) | r;
	info("	%d bip %x r %x\n",i++,bip,r);	
	
	// 1
	r = BIP(bip,1) ^ (( BVAL(3)  ^ BVAL(11) ^ BVAL(19) ^ BVAL(27) ^ BVAL(35) ^ BVAL(43) ^ BVAL(51) ^ BVAL(59) ) << 1);
	bip = BIPN(bip,1) | r;
	info("	%d bip %x r %x\n",i++,bip,r);	

	// 2
	r = (BIP(bip,2) ^ (BVAL(4)  ^ BVAL(12) ^ BVAL(20) ^ BVAL(28) ^ BVAL(36) ^ BVAL(44) ^ BVAL(52) ^ BVAL(60) ) << 2);
	bip = BIPN(bip,2) | r;
	info("	%d bip %x r %x\n",i++,bip,r);	
	
	// 3
	r = (BIP(bip,3) ^ (BVAL(0) ^ BVAL(5)  ^ BVAL(13) ^ BVAL(21) ^ BVAL(29) ^ BVAL(37) ^ BVAL(45) ^ BVAL(53) ^ BVAL(61)) << 3);
	bip = BIPN(bip,3) | r; 
	info("	%d bip %x r %x\n",i++,bip,r);	
	
	// 4
	r = (BIP(bip,4) ^ (BVAL(1) ^ BVAL(6)  ^ BVAL(14) ^ BVAL(22) ^ BVAL(30) ^ BVAL(38) ^ BVAL(46) ^ BVAL(54) ^ BVAL(62)) << 4);
	bip = BIPN(bip,4) | r; 
	info("	%d bip %x r %x\n",i++,bip,r);	
	
	// 5
	r = (BIP(bip,5) ^ (BVAL(7) ^ BVAL(15) ^ BVAL(23) ^ BVAL(31) ^ BVAL(39) ^ BVAL(47) ^ BVAL(55) ^ BVAL(63)) << 5);
	bip = BIPN(bip,5) | r;
	info("	%d bip %x r %x\n",i++,bip,r);	
	
	// 6
	r = (BIP(bip,6) ^ (BVAL(8) ^ BVAL(16) ^ BVAL(24) ^ BVAL(32) ^ BVAL(40) ^ BVAL(48) ^ BVAL(56) ^ BVAL(64)) << 6);
	bip = BIPN(bip,6) | r;
	info("	%d bip %x r %x\n",i++,bip,r);	
	
	// 7
	r = (BIP(bip,7) ^ (BVAL(9) ^ BVAL(17) ^ BVAL(25) ^ BVAL(33) ^ BVAL(41) ^ BVAL(49) ^ BVAL(57) ^ BVAL(65)) << 7);	
	bip = BIPN(bip,7) | r;
	info("	%d bip %x r %x\n",i++,bip,r);	
	return bip;
}

/* Calculate new marker 
 * ieee 802.3 clause 82
 *
 * Table 82–3—40GBASE-R Alignment marker encodings
 *
 * PCS lane  Number Encoding {M0, M1, M2 , BIP3 , M4, M5, M6, BIP7 }
 *      0     0x90, 0x76, 0x47, BIP3 , 0x6F, 0x89, 0xB8, BIP7
 *      1     0xF0, 0xC4, 0xE6, BIP3 , 0x0F, 0x3B, 0x19, BIP7
 *      2     0xC5, 0x65, 0x9B, BIP3 , 0x3A, 0x9A, 0x64, BIP7
 *      3     0xA2, 0x79, 0x3D, BIP3,  0x5D, 0x86, 0xC2, BIP7
 *  Each octet is transmitted LSB to MSB.
*/
void _create_alignement_marker(
	const size_t lane, 
	const uint8_t bip3, 
	block_s *out)
{
	uint8_t bip7 = ~bip3;
	// encoded values
	const uint8_t mark_arr[LANE_N][8] = MARK_LANE_ARR;
	#ifdef DEBUG 	
	info("mark_arr[%d] {",lane);
	for(int i=0; i<8; i++)
		info("%x ,", mark_arr[lane][i]);
	#endif
	out->data = 0;
	for(uint8_t i=0; i<8; i++)
		out->data |= (uint64_t)mark_arr[lane][i] << i*8;
	out->head = SYNC_HEAD_CTRL;
	info("marker lane %d { %lx, %x }  bip3 %x bip7 %x\n",lane, out->data, out->head, bip3, bip7);
}

bool alignement_marker(
	marker_s *state, 
	const size_t lane, 
	const block_s in, 
	block_s *out)
{
	bool need_marker;
	info("bip3 %x\n", state->bip[lane]);
	// check if we need to add marker
	need_marker = is_alignement_marker(*state);
	if ( need_marker ){
		// add alignement data
		_create_alignement_marker(lane, state->bip[lane], out);
		// reset gap counter and bip
		state->bip[lane] = 0;
		if( lane == LANE_N-1 ){
			state->gap = 0;
		}
	}else{
		memcpy(out, &in, sizeof(block_s));	
		if ( lane == LANE_N-1) state->gap ++;
	}
	// continue calculating bip value
	state->bip[lane] = calculate_bip_per_lane(state->bip[lane], *out);	
	// update gap on last lane
	
	return need_marker;
}


