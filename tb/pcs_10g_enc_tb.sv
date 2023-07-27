module pcs_10g_enc_tb;

localparam XGMII_DATA_W = 64;
localparam XGMII_KEEP_W = $clog2(XGMII_DATA_W);
localparam XGMII_CTRL_W = 8;
localparam BLOCK_W = 64;
localparam CNT_N = BLOCK_W/XGMII_DATA_W;
localparam CNT_W = $clog2( CNT_N );
localparam FULL_KEEP_W = CNT_N*XGMII_KEEP_W;
localparam BLOCK_TYPE_W = 8;
localparam CTRL_W  = 7;

localparam [1:0] 
	TYPE_CTRL : 2'b10,
	TYPE_DATA : 2'b01;

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
localparam [XGMII_CTRL_W-1:0] 
	XGMII_CTRL_DATA  = 8'h00,	
	XGMII_CTRL_IDLE  = 8'h07,	
	XGMII_CTRL_START = 8'hfb,	
	XGMII_CTRL_TERM  = 8'hfd,
	XGMII_CTRL_ERR   = 8'hfe;
		

reg   clk = 1'b0;
logic nreset;

always clk = #5 ~clk;
logic [XGMII_DATA_W-1:0]       xgmii_txd_i; // tx data
logic [XGMII_KEEP_W-1:0]       xgmii_txk_i;
logic [XGMII_CTRL_W-1:0]       xgmii_txc_i;
logic                    head_v_o;
logic [1:0]              sync_head_o; 
logic [XGMII_DATA_W-1:0] data_o;	

logic [1:0] exp_head;
logic [BLOCK_TYPE_W-1:0] exp_block_type;


initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, pcs_10g_enc_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	xgmii_txc_i = 8'h07;	
	#20
	
	$display("Sucess");	
	$finish;
end

task check_ctrl();
	case(xgmii_txc_i) begin
		XGMII_CTRL_IDLE : begin // idle
			exp_head = TYPE_CTRL;
			exp_block_type = BLOCK_TYPE_CTRL; 
			end
		XGMII_CTRL_START : begin
			exp_head = TYPE_CTRL;
			exp_block_type = BLOCK_TYPE_START_0;
			end
		XGMII_CTRL_ERR : begin
			exp_head = TYPE_CTRL;
			exp_block_type = BLOCK_TYPE_OS_START
			end
		
	end	 	
endtask

// uut
pcs_10g_enc #(.XGMII_DATA_W(XGMII_DATA_W))
m_pcs_10g_enc(
.clk(clk),
.nreset(nreset),
.xgmii_txd_i(xgmii_txd_i),
.xgmii_txk_i(xgmii_txk_i),
.xgmii_txc_i(xgmii_txc_i ),
.head_v_o(head_v_o),
.sync_head_o(sync_head_o), 
.data_o(data_o)	
);
endmodule
