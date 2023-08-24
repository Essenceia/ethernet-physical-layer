#ifndef PCS_MARKER_H
#define PCS_MARKER_H
#include "pcs_defs.h"

/* Alignement marker specific code, this
 * file should only be compiled if we are
 * targetting a physical layer on 40GBASE
 * or 100GBASE */
#ifndef _40GBASE
#ifndef _100GBASE
#error "Error in defines, alignement marker is a 40G and upper feature"
#endif
#endif
uint8_t calculate_bip_per_lane(
	uint8_t bip, 
	const block_s out);

void _create_alignement_marker(
	const size_t lane, 
	const uint8_t bip3, 
	block_s *out);

// Add alignement marker to data block, return true if an alignement
// marker was added to the block in place of the datad, false if not.
// The block's content will be replaced with an alignement marker 
// once ever 16383 blocks.
bool alignement_marker(
	marker_s *state, 
	const size_t lane, 
	const block_s in, 
	block_s *out);

// are we going to add alignement marker
static inline bool is_alignement_marker(
	const marker_s state)
{
	return ( state.gap == MARKER_GAP_N );
}
#endif//PCS_MARKER_H
