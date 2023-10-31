package require qsys

# create the system "cdc_fifo"
proc do_create_cdc_fifo {} {
	# create the system
	create_system cdc_fifo
	set_project_property DEVICE {10CX150YF780E5G}
	set_project_property DEVICE_FAMILY {Cyclone 10 GX}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance fifo_0 fifo 19.1.1
	set_instance_parameter_value fifo_0 {GUI_AlmostEmpty} {0}
	set_instance_parameter_value fifo_0 {GUI_AlmostEmptyThr} {1}
	set_instance_parameter_value fifo_0 {GUI_AlmostFull} {0}
	set_instance_parameter_value fifo_0 {GUI_AlmostFullThr} {1}
	set_instance_parameter_value fifo_0 {GUI_CLOCKS_ARE_SYNCHRONIZED} {0}
	set_instance_parameter_value fifo_0 {GUI_Clock} {4}
	set_instance_parameter_value fifo_0 {GUI_DISABLE_DCFIFO_EMBEDDED_TIMING_CONSTRAINT} {1}
	set_instance_parameter_value fifo_0 {GUI_Depth} {32}
	set_instance_parameter_value fifo_0 {GUI_ENABLE_ECC} {0}
	set_instance_parameter_value fifo_0 {GUI_Empty} {1}
	set_instance_parameter_value fifo_0 {GUI_Full} {1}
	set_instance_parameter_value fifo_0 {GUI_LE_BasedFIFO} {0}
	set_instance_parameter_value fifo_0 {GUI_LegacyRREQ} {1}
	set_instance_parameter_value fifo_0 {GUI_MAX_DEPTH} {Auto}
	set_instance_parameter_value fifo_0 {GUI_MAX_DEPTH_BY_9} {0}
	set_instance_parameter_value fifo_0 {GUI_OVERFLOW_CHECKING} {1}
	set_instance_parameter_value fifo_0 {GUI_Optimize} {0}
	set_instance_parameter_value fifo_0 {GUI_Optimize_max} {0}
	set_instance_parameter_value fifo_0 {GUI_RAM_BLOCK_TYPE} {Auto}
	set_instance_parameter_value fifo_0 {GUI_TESTBENCH} {0}
	set_instance_parameter_value fifo_0 {GUI_UNDERFLOW_CHECKING} {1}
	set_instance_parameter_value fifo_0 {GUI_UsedW} {1}
	set_instance_parameter_value fifo_0 {GUI_Width} {66}
	set_instance_parameter_value fifo_0 {GUI_dc_aclr} {0}
	set_instance_parameter_value fifo_0 {GUI_delaypipe} {4}
	set_instance_parameter_value fifo_0 {GUI_diff_widths} {0}
	set_instance_parameter_value fifo_0 {GUI_msb_usedw} {0}
	set_instance_parameter_value fifo_0 {GUI_output_width} {8}
	set_instance_parameter_value fifo_0 {GUI_read_aclr_synch} {0}
	set_instance_parameter_value fifo_0 {GUI_rsEmpty} {1}
	set_instance_parameter_value fifo_0 {GUI_rsFull} {0}
	set_instance_parameter_value fifo_0 {GUI_rsUsedW} {0}
	set_instance_parameter_value fifo_0 {GUI_sc_aclr} {0}
	set_instance_parameter_value fifo_0 {GUI_sc_sclr} {0}
	set_instance_parameter_value fifo_0 {GUI_synStage} {3}
	set_instance_parameter_value fifo_0 {GUI_write_aclr_synch} {0}
	set_instance_parameter_value fifo_0 {GUI_wsEmpty} {0}
	set_instance_parameter_value fifo_0 {GUI_wsFull} {0}
	set_instance_parameter_value fifo_0 {GUI_wsUsedW} {0}
	set_instance_property fifo_0 AUTO_EXPORT true

	# add wirelevel expressions

	# preserve ports for debug

	# add the exports
	set_interface_property fifo_input EXPORT_OF fifo_0.fifo_input
	set_interface_property fifo_output EXPORT_OF fifo_0.fifo_output

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="fifo_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {cdc_fifo.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {cdc_fifo}

	# save the system
	sync_sysinfo_parameters
	save_system cdc_fifo
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_cdc_fifo

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
