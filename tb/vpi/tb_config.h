/* Copyright (c) 2023, Julia Desmazes. All rights reserved.
 * 
 * This work is licensed under the Creative Commons Attribution-NonCommercial
 * 4.0 International License. 
 * 
 * This code is provided "as is" without any express or implied warranties. */ 

#ifndef TB_CONFIG_H
#define TB_CONFIG_H


#ifndef RAND_SEED
#define RAND_SEED 10
#endif

// packet length
#define PACKET_LEN_MIN 30
#define PACKET_LEN_MAX 150

#define PACKET_IDLE_CNT_MIN 2
#define PACKET_IDLE_CNT_MAX 4

#endif//TB_CONFIG_H
