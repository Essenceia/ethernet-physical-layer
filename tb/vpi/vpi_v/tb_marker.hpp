#ifndef TB_MARKER_HPP 
#define TB_MARKER_HPP 

#define MODULE am_tx_tb

#define STR_(x) #x
#define STR(x) STR_(x)


#define CAT2_(a,b) a##b
#define CAT2(a,b) CAT2_(a,b)

#define CAT3_(a,b,c) a##b##c
#define CAT3(a,b,c) CAT3_(a,b,c)

#define INC_STR STR(CAT2(V,MODULE).h)
#define VMODULE CAT2(V,MODULE)
#define MODULE_SIG_STR(x) STR(CAT3(TOP.,MODULE,.)x)

#include INC_STR

int main(int argc, char ** argv);

#endif
