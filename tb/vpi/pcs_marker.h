#ifndef PCS_MARKER_H
#define PCS_MARKER_H
#include "pcs_defs.h"

uint8_t calculate_bip_per_lane(const block_s out);

void _create_alignement_marker(const uint8_t bip3[LANE_N],block_s out[LANE_N]);

// Add alignement marker to data block, return true if an alignement
// marker was added to the block in place of the datad, false if not.
// The block's content will be replaced with an alignement marker 
// once ever 16383 blocks.
bool alignement_marker(marker_s *state, block_s in[LANE_N], block_s out[LANE_N]);

// are we going to add alignement marker
static inline bool is_alignement_marker(const marker_s state){
	return ( state.gap == MARKER_GAP_N );
}
#endif//PCS_MARKER_H
