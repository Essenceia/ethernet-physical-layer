/* PCS decode block, use on rx path.
* Received block data may be invalid if it is
* deemed malformed.
*/
module pcs_dec_lite #(
	parameter IS_40G = 0,
	parameter HEAD_W = 2,
	parameter DATA_W = 64,
	parameter KEEP_W = DATA_W/8,
	parameter BLOCK_W = 64,
	parameter LANE0_CNT_N = IS_40G ? 1 : BLOCK_W/( 4 * 8),
	parameter BLOCK_TYPE_W = 8
)(
	input [HEAD_W-1:0] head_i,
	input [DATA_W-1:0] data_i,

	// lite dec interface, not x(l)gmii interface
	output                    ctrl_v_o,
	output                    idle_v_o,
	output [LANE0_CNT_N-1:0]  start_v_o,
	output                    term_v_o,
	output                    err_v_o,
	output                    ord_v_o,
	output [DATA_W-1:0]       data_o, // x(l)gmii data
	output [KEEP_W-1:0]       keep_o
);
localparam [BLOCK_TYPE_W-1:0]
    BLOCK_TYPE_CTRL     = 8'h1e, // C7 C6 C5 C4 C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_4     = 8'h2d, // D7 D6 D5 O4 C3 C2 C1 C0 BT
    BLOCK_TYPE_START_4  = 8'h33, // D7 D6 D5    C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_START = 8'h66, // D7 D6 D5    O0 D3 D2 D1 BT
    BLOCK_TYPE_OS_04    = 8'h55, // D7 D6 D5 O4 O0 D3 D2 D1 BT
    BLOCK_TYPE_START_0  = 8'h78, // D7 D6 D5 D4 D3 D2 D1    BT
    BLOCK_TYPE_OS_0     = 8'h4b, // C7 C6 C5 C4 O0 D3 D2 D1 BT
    BLOCK_TYPE_TERM_0   = 8'h87, // C7 C6 C5 C4 C3 C2 C1    BT
    BLOCK_TYPE_TERM_1   = 8'h99, // C7 C6 C5 C4 C3 C2    D0 BT
    BLOCK_TYPE_TERM_2   = 8'haa, // C7 C6 C5 C4 C3    D1 D0 BT
    BLOCK_TYPE_TERM_3   = 8'hb4, // C7 C6 C5 C4    D2 D1 D0 BT
    BLOCK_TYPE_TERM_4   = 8'hcc, // C7 C6 C5    D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_5   = 8'hd2, // C7 C6    D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_6   = 8'he1, // C7    D5 D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_7   = 8'hff; //    D6 D5 D4 D3 D2 D1 D0 BT

// recieved block data is invalid, it is malformed.
// follows rules outlined in 49.2.4.6
logic block_nv; 

// head
logic  head_v; // head is wellformed
assign head_v = head_i[0] ^ head_i[1];


// look for matching control code
logic [BLOCK_TYPE_W-1:0] block_type;
logic                    block_type_none; 
logic                    idle_lite; 
logic                    err_lite; 
logic                    ord_lite; // ordered set
logic [KEEP_W-1:0]       term_lite; 
logic [LANE0_CNT_N-1:0]  start_lite; 
logic                    idle_v; 
logic                    err_v; 
logic                    ord_v; // ordered set
logic [KEEP_W-1:0]       term_v; 
logic [LANE0_CNT_N-1:0]  start_v; 

assign block_type = data_i[BLOCK_TYPE_W-1:0];

assign idle_lite = ~|block_type; // 0x0
assign err_lite  = block_type == BLOCK_TYPE_CTRL;
assign ord_lite  = 1'b0; // TODO : add support for order set codes 

assign term_lite[0] = block_type == BLOCK_TYPE_TERM_0;  
assign term_lite[1] = block_type == BLOCK_TYPE_TERM_1;  
assign term_lite[2] = block_type == BLOCK_TYPE_TERM_2;  
assign term_lite[3] = block_type == BLOCK_TYPE_TERM_3;  
assign term_lite[4] = block_type == BLOCK_TYPE_TERM_4;  
assign term_lite[5] = block_type == BLOCK_TYPE_TERM_5;  
assign term_lite[6] = block_type == BLOCK_TYPE_TERM_6;  
assign term_lite[7] = block_type == BLOCK_TYPE_TERM_7;  

assign start_lite[0] = block_type == BLOCK_TYPE_START_0;
if ( !IS_40G ) begin
assign start_lite[1] = block_type == BLOCK_TYPE_START_4;
end 
// no valid control code was dound 
assign block_type_none = ~( idle_lite | err_lite | ord_lite | |term_lite | |start_lite );  

// mask control code if the block is invalid
assign err_v  = err_lite | block_nv; 
assign idle_v  = idle_lite & ~block_nv;
assign ord_v   = ord_lite  & ~block_nv; 
assign term_v  = term_lite  & {KEEP_W{~block_nv}};
assign start_v = start_lite & {LANE0_CNT_N{~block_nv}};

// keep signal value
// this signal exists only in our implementation, as such it doesn't follow 802.3
// as we will not be using start_4 our keep signal doesn't show a correct mask for
// that case ( 8'b1110_0000 ).
// keep signal is only valid for term
assign keep_o = term_lite - 'd1; 

// check if block is valid
assign block_nv = ~head_v | block_type_none;

// output
// check if we have ctrl, or reception error
assign ctrl_v_o = head_i[1] | block_nv; 

assign idle_v_o  = idle_v;
assign err_v_o   = err_v;
assign ord_v_o   = ord_v;
assign term_v_o  = |term_v;
assign start_v_o = start_v;

assign data_o = data_i;

`ifdef FORMAL
`endif
endmodule
