#include "tb_marker.hpp"
#include "verilated.h"
#include "verilated_vpi.h"  // Required to get definitions
#include "../tb_marker_common.h"

#if VM_TRACE
# include <verilated_vcd_c.h>	// Trace file format header
#endif

uint64_t main_time = 0;   // See comments in first example
double sc_time_stamp() { return main_time; }


int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);


	const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    const std::unique_ptr<VMODULE> top{new VMODULE{contextp.get()}};

	#if VM_TRACE // makefile wave invoked with wave=1 
    Verilated::traceEverOn(true);// computer trace signals
    VL_PRINTF("Enabling waves...\n");
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 5);// trace 5 levels of hierachy
    tfp->open ("wave/"STR(MODULE)".vcd");	// Open the dump file
	#endif


    //contextp->internalsDump();  // See scopes to help debug

	// vpiHandlers
	vpiHandle h_head_i = vpi_handle_by_name((PLI_BYTE8*)"TOP.am_tx_tb.head_i", NULL);
	vpiHandle h_data_i = vpi_handle_by_name((PLI_BYTE8*)"TOP.am_tx_tb.data_i", NULL);
	vpiHandle h_marker_v_o = vpi_handle_by_name((PLI_BYTE8*)"TOP.am_tx_tb.tb_marker_v_o", NULL);
	vpiHandle h_head_o = vpi_handle_by_name((PLI_BYTE8*)"TOP.am_tx_tb.tb_head_o", NULL);
	vpiHandle h_data_o = vpi_handle_by_name((PLI_BYTE8*)"TOP.am_tx_tb.tb_data_o", NULL);

	/* reset sequence
	* Hold reset for 1 clk cycle -> 10 C cycles */
	for(; main_time<18; main_time++){
		top->eval();
		#if VM_TRACE
		if (tfp) tfp->dump (main_time);	// Create waveform trace for this timestamp
		#endif
	}
    while (!contextp->gotFinish()) {
        top->eval();
        VerilatedVpi::callValueCbs();  // For signal callbacks
		if ( main_time % 10 == 0 ){
        	tb_marker(h_head_i,h_data_i,h_marker_v_o, 
				h_head_o,h_data_o);
		}
		#if VM_TRACE
		if (tfp) tfp->dump (main_time);	// Create waveform trace for this timestamp
		#endif

		main_time++;
    }


	#if VM_TRACE
    if (tfp) tfp->close();
	#endif

    return 0;
}
