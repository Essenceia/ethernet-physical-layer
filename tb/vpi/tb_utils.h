/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#ifndef TB_UTILS_H
#define TB_UTILS_H
#include <vpi_user.h>
void tb_vpi_put_logic_1b_t(vpiHandle argv, uint8_t var);

void tb_vpi_put_logic_uint8_t(vpiHandle argv, uint8_t var);

void tb_vpi_put_logic_uint32_t(vpiHandle argv, uint32_t var);

static inline void tb_vpi_put_logic_uint16_t(vpiHandle argv, uint16_t var){
	tb_vpi_put_logic_uint32_t(argv, (uint32_t) var);
};

void tb_vpi_put_logic_uint64_t(vpiHandle argv, uint64_t var);


// puts an array of char of variable length to a vector
void _tb_vpi_put_logic_char_var_arr(vpiHandle argv, char *arr, size_t len);

#define TB_UTILS_PUT_CHAR_ARR(X) \
 static inline void tb_vpi_put_logic_char_##X##_t(vpiHandle argv, char *arr){ \
	_tb_vpi_put_logic_char_var_arr( argv, arr, X ); \
}
static inline void tb_vpi_put_logic_char(vpiHandle argc, char var){
	tb_vpi_put_logic_uint8_t(argc, (uint8_t) var);
 }
TB_UTILS_PUT_CHAR_ARR(2)
TB_UTILS_PUT_CHAR_ARR(4)
TB_UTILS_PUT_CHAR_ARR(8)
TB_UTILS_PUT_CHAR_ARR(10)
TB_UTILS_PUT_CHAR_ARR(20)

// debug id
TB_UTILS_PUT_CHAR_ARR(18)


#endif // TB_UTILS_H