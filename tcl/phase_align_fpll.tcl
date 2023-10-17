package require qsys

# create the system "phase_align_fpll"
proc do_create_phase_align_fpll {} {
	# create the system
	create_system phase_align_fpll
	
	set_project_property DEVICE {10CX150YF780E5G}
	set_project_property DEVICE_FAMILY {Cyclone 10 GX}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance xcvr_fpll_a10_0 altera_xcvr_fpll_a10 19.1
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_analog_resets} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_bonding_clks} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_ext_lockdetect_ports} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_fb_comp_bonding} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_hfreq_clk} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_mcgb} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_mcgb_pcie_clksw} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_pld_mcgb_cal_busy_port} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {enable_pll_reconfig} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {generate_add_hdl_instance_example} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {generate_docs} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_actual_outclk0_frequency} {161.1328}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_actual_outclk1_frequency} {100.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_actual_outclk2_frequency} {100.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_actual_outclk3_frequency} {100.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_actual_refclk_frequency} {161.1328}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_bw_sel} {high}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_cascade_outclk_index} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_desired_hssi_cascade_frequency} {100.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_desired_outclk0_frequency} {161.1328}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_desired_outclk1_frequency} {161.1328}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_desired_outclk2_frequency} {100.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_desired_outclk3_frequency} {100.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_desired_refclk_frequency} {161.1328}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_50G_support} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_active_clk} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_cascade_out} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_clk_bad} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_dps} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_fractional} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_hip_cal_done_port} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_manual_config} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_manual_hssi_counters} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_phase_alignment} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_enable_pld_cal_busy_port} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_fpll_mode} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_fractional_x} {32}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_hip_cal_en} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_hssi_output_clock_frequency} {1250.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_hssi_prot_mode} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_iqtxrxclk_outclk_index} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_is_downstream_cascaded_pll} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_number_of_output_clocks} {2}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_operation_mode} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk0_actual_phase_shift} {0.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk0_actual_phase_shift_deg} {0.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk0_desired_phase_shift} {0.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk0_phase_shift_unit} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk1_actual_phase_shift} {0.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk1_actual_phase_shift_deg} {0.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk1_desired_phase_shift} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk1_phase_shift_unit} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk2_actual_phase_shift} {0 ps}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk2_actual_phase_shift_deg} {0 deg}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk2_desired_phase_shift} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk2_phase_shift_unit} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk3_actual_phase_shift} {0.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk3_actual_phase_shift_deg} {0.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk3_desired_phase_shift} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_outclk3_phase_shift_unit} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_c_counter_0} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_c_counter_1} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_c_counter_2} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_c_counter_3} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_dsm_fractional_division} {1.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_m_counter} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_n_counter} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_set_hssi_k_counter} {1.0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_set_hssi_l_counter} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_set_hssi_m_counter} {8}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_pll_set_hssi_n_counter} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_refclk1_frequency} {161.1328}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_refclk_cnt} {2}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_refclk_index} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_refclk_switch} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_reference_clock_frequency} {161.1328}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_self_reset_enabled} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_switchover_delay} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {gui_switchover_mode} {Automatic Switchover}
	set_instance_parameter_value xcvr_fpll_a10_0 {mcgb_aux_clkin_cnt} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {mcgb_div} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {phase_alignment_check_var} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {pma_width} {64}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_debug} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_enable_avmm_busy_port} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_file_prefix} {altera_xcvr_fpll_a10}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_h_file_enable} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_jtag_enable} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_mif_file_enable} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_separate_avmm_busy} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_sv_file_enable} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {rcfg_txt_file_enable} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {set_altera_xcvr_fpll_a10_calibration_en} {1}
	set_instance_parameter_value xcvr_fpll_a10_0 {set_capability_reg_enable} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {set_csr_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {set_user_identifier} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {silicon_rev} {0}
	set_instance_parameter_value xcvr_fpll_a10_0 {support_mode} {user_mode}
	set_instance_property xcvr_fpll_a10_0 AUTO_EXPORT true

	# add wirelevel expressions

	# preserve ports for debug

	# add the exports
	set_interface_property pll_refclk0 EXPORT_OF xcvr_fpll_a10_0.pll_refclk0
	set_interface_property pll_refclk1 EXPORT_OF xcvr_fpll_a10_0.pll_refclk1
	set_interface_property pll_powerdown EXPORT_OF xcvr_fpll_a10_0.pll_powerdown
	set_interface_property pll_locked EXPORT_OF xcvr_fpll_a10_0.pll_locked
	set_interface_property outclk0 EXPORT_OF xcvr_fpll_a10_0.outclk0
	set_interface_property outclk1 EXPORT_OF xcvr_fpll_a10_0.outclk1
	set_interface_property pll_cal_busy EXPORT_OF xcvr_fpll_a10_0.pll_cal_busy

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="xcvr_fpll_a10_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {phase_align_fpll.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {phase_align_fpll}

	# save the system
	sync_sysinfo_parameters
	save_system phase_align_fpll
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_phase_align_fpll

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
