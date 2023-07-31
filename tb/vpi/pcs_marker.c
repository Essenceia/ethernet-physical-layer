#include "pcs_marker.h"
#include <string.h>
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
/* Calculate new bip value
 * head has index [1:0]
 * data          [63:0] */
uint8_t calculate_bip_per_lane(const block_s out){
	uint8_t bip = 0;
	uint64_t data = out.data;
	uint8_t  head = out.head;
	bip = BVAL(2) ^ BVAL(10) ^ BVAL(18) ^ BVAL(26) ^ BVAL(34) ^ BVAL(42) ^ BVAL(50) ^ BVAL(58);
	bip = bip | ( BVAL(3) ^ BVAL(11) ^ BVAL(19) ^ BVAL(27) ^ BVAL(35) ^ BVAL(43) ^ BVAL(51) ^ BVAL(59) ) << 1;
	bip = bip | ( BVAL(4) ^ BVAL(12) ^ BVAL(20) ^ BVAL(28) ^ BVAL(36) ^ BVAL(44) ^ BVAL(52) ^ BVAL(60) ) << 2;
	bip = bip | ( BVAL(0) ^ BVAL(5)  ^ BVAL(13) ^ BVAL(21) ^ BVAL(29) ^ BVAL(37) ^ BVAL(45) ^ BVAL(53) ^ BVAL(61) ) << 3;
	bip = bip | ( BVAL(1) ^ BVAL(6)  ^ BVAL(14) ^ BVAL(22) ^ BVAL(30) ^ BVAL(38) ^ BVAL(46) ^ BVAL(54) ^ BVAL(62) ) << 4;
	bip = bip | ( BVAL(7) ^ BVAL(15) ^ BVAL(23) ^ BVAL(31) ^ BVAL(39) ^ BVAL(47) ^ BVAL(55) ^ BVAL(63) ) << 5;
	bip = bip | ( BVAL(8) ^ BVAL(16) ^ BVAL(24) ^ BVAL(32) ^ BVAL(40) ^ BVAL(48) ^ BVAL(56) ^ BVAL(64) ) << 6;
	bip = bip | ( BVAL(9) ^ BVAL(17) ^ BVAL(25) ^ BVAL(33) ^ BVAL(41) ^ BVAL(49) ^ BVAL(57) ^ BVAL(65) ) << 7;	
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
void _create_alignement_marker(const size_t lane, const uint8_t bip3, block_s *out){
	uint8_t bip7;
	bip7 = ~bip3;
	// encoded values
	const uint8_t mark_arr[LANE_N][8] = MARK_LANE_ARR;
	memcpy(&out->data ,mark_arr[lane], sizeof(uint64_t));
	out->head = SYNC_HEAD_CTRL;
}

bool alignement_marker(marker_s *state, const size_t lane, const block_s in, block_s *out){
	bool need_marker;
	// check if we need to add marker
	need_marker = state->gap == MARKER_GAP_N+1;
	if ( need_marker ){
		// add alignement data
		_create_alignement_marker(lane, state->bip[lane], out);
		// reset gap counter and bip
		state->gap = 0;
		memset( state->bip, 0, sizeof(uint8_t) * LANE_N );// TODO : confirm we need to reset bip to 0
	}else{
		memcpy(out, &in, sizeof(block_s));	
	}
	// continue calculating bip value
	state->bip[lane] = calculate_bip_per_lane(in);	
	// update gap on last lane
	if ( lane == LANE_N-1) state->gap ++;
	
	return need_marker;
}


