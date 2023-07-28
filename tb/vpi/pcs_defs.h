#ifndef PCS_DEFS_H
#define PCS_DEFS_H
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#ifdef _40GBASE
#define START_W 1
#define LANE_N  4
#else
#define START_W 2	
#define LANE_N  1
#endif
#define    XGMII_CTRL_IDLE      (uint8_t) 0x07
#define    XGMII_CTRL START     (uint8_t) 0xfb
#define    XGMII_CTRL_TERMINATE (uint8_t) 0xfb
#define    XGMII_CTRL_ERROR     (uint8_t) 0xfe

#define    BLOCK_TYPE_CTRL     (uint8_t) 0x1e // C7 C6 C5 C4 C3 C2 C1 C0 BT
#define    BLOCK_TYPE_OS_4     (uint8_t) 0x2d // D7 D6 D5 O4 C3 C2 C1 C0 BT
#define    BLOCK_TYPE_START_4  (uint8_t) 0x33 // D7 D6 D5    C3 C2 C1 C0 BT
#define    BLOCK_TYPE_OS_START (uint8_t) 0x66 // D7 D6 D5    O0 D3 D2 D1 BT
#define    BLOCK_TYPE_OS_04    (uint8_t) 0x55 // D7 D6 D5 O4 O0 D3 D2 D1 BT
#define    BLOCK_TYPE_START_0  (uint8_t) 0x78 // D7 D6 D5 D4 D3 D2 D1    BT
#define    BLOCK_TYPE_OS_0     (uint8_t) 0x4b // C7 C6 C5 C4 O0 D3 D2 D1 BT
#define    BLOCK_TYPE_TERM_0   (uint8_t) 0x87 // C7 C6 C5 C4 C3 C2 C1    BT
#define    BLOCK_TYPE_TERM_1   (uint8_t) 0x99 // C7 C6 C5 C4 C3 C2    D0 BT
#define    BLOCK_TYPE_TERM_2   (uint8_t) 0xaa // C7 C6 C5 C4 C3    D1 D0 BT
#define    BLOCK_TYPE_TERM_3   (uint8_t) 0xb4 // C7 C6 C5 C4    D2 D1 D0 BT
#define    BLOCK_TYPE_TERM_4   (uint8_t) 0xcc // C7 C6 C5    D3 D2 D1 D0 BT
#define    BLOCK_TYPE_TERM_5   (uint8_t) 0xd2 // C7 C6    D4 D3 D2 D1 D0 BT
#define    BLOCK_TYPE_TERM_6   (uint8_t) 0xe1 // C7    D5 D4 D3 D2 D1 D0 BT
#define    BLOCK_TYPE_TERM_7   (uint8_t) 0xff //    D6 D5 D4 D3 D2 D1 D0 BT

#define BLOCK_CTRL_IDLE (uint64_t) 0x00
#define BLOCK_CTRL_ERR  (uint64_t) 0b00111100011110001111000111100011110001111000111100011110// 8{7'h1e}

#define SYNC_HEAD_CTRL (uint8_t) 0x02
#define SYNC_HEAD_DATA (uint8_t) 0x01

#define I0_64b66b 38
#define I1_64b66b 58

typedef unsigned __int128 uint128_t;

typedef struct {
	uint8_t  head;
	uint64_t data;
}block_s;

typedef struct{
	bool ctrl_v;
	bool idle_v;
	bool start_v[START_W];
	bool term_v;
	uint8_t term_keep;
	bool err_v;
}ctrl_lite_s;

typedef struct{
	uint128_t buff;
	size_t    len;
}gearbox_s;

typedef struct{
	block_s     block_enc[LANE_N];
	uint64_t    scrambler_state[LANE_N];
	block_s     block_scram[LANE_N];
	gearbox_s   gearbox_state[LANE_N];
}pcs_tx_s;


#endif // PCS_DEFS_H
