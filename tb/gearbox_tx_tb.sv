module gearbox_tx_tb;
localparam BLOCK_DATA_W = 64;
localparam DATA_W = 64;
localparam HEAD_W = 2;
localparam SEQ_N = DATA_W/HEAD_W + 1;
localparam SEQ_W  = $clog2(SEQ_N);
localparam TB_BUF_W = SEQ_N * ( HEAD_W + DATA_W );

reg   clk = 1'b0;
logic nreset;

logic [SEQ_W-1:0]  seq_i;
logic [HEAD_W-1:0] head_i;
logic [DATA_W-1:0] data_i;
logic              full_v_o; // backpressure, buffer is full, need a cycle to clear 
logic [DATA_W-1:0] data_o;

logic [TB_BUF_W-1:0] tb_buf;
reg [TB_BUF_W-1:0] got_buf;

always clk = #5 ~clk;

// generate a random array of 66b of data for a given sequence and
// check it is correctly outputed aligned on 64b
task new_seq();
	// set default values
	int seq;
	logic [HEAD_W-1:0] h;
	logic [DATA_W-1:0] d;
	for( int seq = 0; seq< SEQ_N; seq++ ) begin
		h = 2'b11;
		d = { $random(), $random() };
		// fill tb buffer
		tb_buf = { d, h, tb_buf[TB_BUF_W-(HEAD_W+DATA_W)-1:0] };
		// drive uut
		seq_i = seq;
		head_i = h;
		data_i = d;
		#10
		$display("Seq %d", seq);
	end	
endtask

always @(posedge clk) begin
	got_buf <= { data_o, got_buf[TB_BUF_W-DATA_W-1:0] };	
end

initial begin
	$dumpfile("build/wave.vcd");
	$dumpvars(0, gearbox_tx_tb);
	nreset = 1'b0;
	#10
	nreset = 1'b1;
	#10
	new_seq();
	#10
	for( int l=0; l < TB_BUF_W; l++) begin
		if (got_buf[l] != tb_buf[l] ) begin
			$display("Error matching returned data, index %d",l);
			assert(0);
			$finish;
		end
	end	
	$display("Sucess");	
	$finish;
end

// uut 
gearbox_tx #(.DATA_W(DATA_W))
m_gearbox_tx(
.clk(clk),
.nreset(nreset),
.seq_i(seq_i),
.head_i(head_i),
.data_i(data_i),
.full_v_o(full_v_o),
.data_o(data_o)
);
endmodule
