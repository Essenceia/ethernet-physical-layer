#include "tb_pcs.hpp"
#include "verilated.h"
#include "verilated_vpi.h"  // Required to get definitions
#include "../tb_pcs_common.h"

#if VM_TRACE
# include <verilated_vcd_c.h>	// Trace file format header
#endif

uint64_t main_time = 0;   // See comments in first example
double sc_time_stamp() { return main_time; }


int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
	tv_t *tv_s = tv_alloc();

	const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    const std::unique_ptr<VMODULE> top{new VMODULE{contextp.get()}};

	#if VM_TRACE // makefile wave invoked with wave=1 
    Verilated::traceEverOn(true);// computer trace signals
    VL_PRINTF("Enabling waves...\n");
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 15);// trace 15 levels of hierachy
    tfp->open ("wave/"STR(MODULE)".vcd");	// Open the dump file
	#endif


    //contextp->internalsDump();  // See scopes to help debug

	// vpiHandlers
	vpiHandle h_ready_o = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".ready_o", NULL);
	vpiHandle h_ctrl_v_i = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".ctrl_v_i", NULL);
	vpiHandle h_idle_v_i = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".idle_v_i", NULL);
	vpiHandle h_start_v_i = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".start_v_i", NULL);
	vpiHandle h_term_v_i = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".term_v_i", NULL);
	vpiHandle h_keep_i = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".keep_i", NULL);
	vpiHandle h_err_v_i = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".err_v_i", NULL);
	vpiHandle h_data_i = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".data_i", NULL);
	vpiHandle h_debug_id = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".data_debug_id", NULL);
	
	vpiHandle h_pma = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".tb_pma", NULL);
	vpiHandle h_pma_debug_id = vpi_handle_by_name((PLI_BYTE8*)"TOP."STR(MODULE)".pma_debug_id", NULL);

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
			// pcs
        	tb_pcs_tx(tv_s,	
				h_ready_o,
				h_ctrl_v_i,
				h_idle_v_i,
				h_start_v_i,
				h_term_v_i,
				h_keep_i,
				h_err_v_i,
				h_data_i,
				h_debug_id);
			// exp
			tb_pcs_tx_exp(tv_s,
				h_pma,
				h_pma_debug_id);
		}
		#if VM_TRACE
		if (tfp) tfp->dump (main_time);	// Create waveform trace for this timestamp
		#endif

		main_time++;
    }


	#if VM_TRACE
    if (tfp) tfp->close();
	#endif
	
	// free
	tv_free(tv_s);

    return 0;
}
