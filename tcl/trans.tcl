package require -exact qsys 21.3

# create the system "trans"
proc do_create_trans {} {
	# create the system
	create_system trans
	set_project_property BOARD {default}
	set_project_property DEVICE {10CX150YF780E5G}
	set_project_property DEVICE_FAMILY {Cyclone 10 GX}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance xcvr_native_a10_0 altera_xcvr_native_a10 19.1
	set_instance_parameter_value xcvr_native_a10_0 {anlg_enable_rx_default_ovr} {0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_enable_tx_default_ovr} {0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_link} {sr}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_ctle_acgain_4s} {radp_ctle_acgain_4s_1}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_ctle_eqz_1s_sel} {radp_ctle_eqz_1s_sel_3}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap1} {radp_dfe_fxtap1_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap10} {radp_dfe_fxtap10_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap11} {radp_dfe_fxtap11_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap2} {radp_dfe_fxtap2_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap3} {radp_dfe_fxtap3_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap4} {radp_dfe_fxtap4_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap5} {radp_dfe_fxtap5_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap6} {radp_dfe_fxtap6_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap7} {radp_dfe_fxtap7_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap8} {radp_dfe_fxtap8_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_dfe_fxtap9} {radp_dfe_fxtap9_0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_adp_vga_sel} {radp_vga_sel_2}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_eq_dc_gain_trim} {stg2_gain7}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_one_stage_enable} {s1_mode}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_rx_term_sel} {r_r1}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_analog_mode} {user_custom}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_compensation_en} {enable}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_sign_1st_post_tap} {fir_post_1t_neg}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_sign_2nd_post_tap} {fir_post_2t_neg}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_sign_pre_tap_1t} {fir_pre_1t_neg}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_sign_pre_tap_2t} {fir_pre_2t_neg}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_switching_ctrl_1st_post_tap} {0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_switching_ctrl_2nd_post_tap} {0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_switching_ctrl_pre_tap_1t} {0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_pre_emp_switching_ctrl_pre_tap_2t} {0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_slew_rate_ctrl} {slew_r7}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_term_sel} {r_r1}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_tx_vod_output_swing_ctrl} {0}
	set_instance_parameter_value xcvr_native_a10_0 {anlg_voltage} {1_0V}
	set_instance_parameter_value xcvr_native_a10_0 {bonded_mode} {not_bonded}
	set_instance_parameter_value xcvr_native_a10_0 {cdr_refclk_cnt} {1}
	set_instance_parameter_value xcvr_native_a10_0 {cdr_refclk_select} {0}
	set_instance_parameter_value xcvr_native_a10_0 {channels} {1}
	set_instance_parameter_value xcvr_native_a10_0 {design_environment} {NATIVE}
	set_instance_parameter_value xcvr_native_a10_0 {disable_continuous_dfe} {0}
	set_instance_parameter_value xcvr_native_a10_0 {duplex_mode} {duplex}
	set_instance_parameter_value xcvr_native_a10_0 {enable_analog_settings} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_hard_reset} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_hip} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_parallel_loopback} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_pcie_data_mask_option} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_pcie_dfe_ip} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_krfec_rx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_krfec_rx_enh_frame_diag_status} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_krfec_tx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_pipe_rx_polarity} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_analog_reset_ack} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_bitslip} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_blk_lock} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_clr_errblk_count} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_clr_errblk_count_c10} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_crc32_err} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_data_valid} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_align_clr} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_align_val} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_cnt} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_del} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_empty} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_full} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_insert} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_pempty} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_pfull} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_fifo_rd_en} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_frame_diag_status} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_frame_lock} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_highber} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_enh_highber_clr_cnt} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_is_lockedtodata} {1}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_is_lockedtoref} {1}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_pma_clkout} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_pma_clkslip} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_pma_div_clkout} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_pma_iqtxrx_clkout} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_pma_qpipulldn} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_polinv} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_seriallpbken} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_seriallpbken_tx} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_signaldetect} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_bitrev_ena} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_bitslip} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_bitslipboundarysel} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_byterev_ena} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_pcfifo_empty} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_pcfifo_full} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_rmfifo_empty} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_rmfifo_full} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_signaldetect} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_wa_a1a2size} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_rx_std_wa_patternalign} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_analog_reset_ack} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_bitslip} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_fifo_cnt} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_fifo_empty} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_fifo_full} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_fifo_pempty} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_fifo_pfull} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_frame_burst_en} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_enh_frame_diag_status} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_clkout} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_div_clkout} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_elecidle} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_iqtxrx_clkout} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_qpipulldn} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_qpipullup} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_rxfound} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_pma_txdetectrx} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_polinv} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_std_bitslipboundarysel} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_std_pcfifo_empty} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_port_tx_std_pcfifo_full} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_adaptation} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_pipe_g3_analog} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_pipe_hclk} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_pipe_rx_elecidle} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_pipe_sw} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_rx_manual_cdr_mode} {1}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_rx_manual_ppm} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_ports_rx_prbs} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_simple_interface} {1}
	set_instance_parameter_value xcvr_native_a10_0 {enable_skp_ports} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_split_interface} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_transparent_pcs} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enable_upi_pipeline_options} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_low_latency_enable} {1}
	set_instance_parameter_value xcvr_native_a10_0 {enh_pcs_pma_width} {40}
	set_instance_parameter_value xcvr_native_a10_0 {enh_pld_pcs_width} {40}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_64b66b_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_bitslip_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_blksync_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_crcchk_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_descram_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_dispchk_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_frmsync_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_frmsync_mfrm_length} {2048}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_krfec_err_mark_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_krfec_err_mark_type} {10G}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rxfifo_align_del} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rxfifo_control_del} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rxfifo_mode} {Phase compensation}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rxfifo_pempty} {2}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rxfifo_pfull} {23}
	set_instance_parameter_value xcvr_native_a10_0 {enh_rxtxfifo_double_width} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_64b66b_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_bitslip_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_crcerr_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_crcgen_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_dispgen_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_frmgen_burst_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_frmgen_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_frmgen_mfrm_length} {2048}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_krfec_burst_err_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_krfec_burst_err_len} {1}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_randomdispbit_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_scram_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_scram_seed} {2.0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_tx_sh_err} {0}
	set_instance_parameter_value xcvr_native_a10_0 {enh_txfifo_mode} {Phase compensation}
	set_instance_parameter_value xcvr_native_a10_0 {enh_txfifo_pempty} {2}
	set_instance_parameter_value xcvr_native_a10_0 {enh_txfifo_pfull} {11}
	set_instance_parameter_value xcvr_native_a10_0 {generate_add_hdl_instance_example} {0}
	set_instance_parameter_value xcvr_native_a10_0 {generate_docs} {1}
	set_instance_parameter_value xcvr_native_a10_0 {message_level} {error}
	set_instance_parameter_value xcvr_native_a10_0 {number_physical_bonding_clocks} {1}
	set_instance_parameter_value xcvr_native_a10_0 {pcie_rate_match} {Bypass}
	set_instance_parameter_value xcvr_native_a10_0 {pcs_direct_width} {64}
	set_instance_parameter_value xcvr_native_a10_0 {pcs_tx_delay1_ctrl} {delay1_path0}
	set_instance_parameter_value xcvr_native_a10_0 {pcs_tx_delay1_data_sel} {one_ff_delay}
	set_instance_parameter_value xcvr_native_a10_0 {pcs_tx_delay2_ctrl} {delay2_path0}
	set_instance_parameter_value xcvr_native_a10_0 {pll_select} {0}
	set_instance_parameter_value xcvr_native_a10_0 {plls} {1}
	set_instance_parameter_value xcvr_native_a10_0 {pma_mode} {basic}
	set_instance_parameter_value xcvr_native_a10_0 {protocol_mode} {pcs_direct}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_enable_avmm_busy_port} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_file_prefix} {altera_xcvr_native_a10}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_h_file_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_iface_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_jtag_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_mif_file_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_multi_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_cnt} {2}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data0} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data1} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data2} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data3} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data4} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data5} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data6} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_data7} {}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_profile_select} {1}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_reduced_files_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_separate_avmm_busy} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_shared} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rcfg_sv_file_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rx_pma_ctle_adaptation_mode} {manual}
	set_instance_parameter_value xcvr_native_a10_0 {rx_pma_dfe_adaptation_mode} {disabled}
	set_instance_parameter_value xcvr_native_a10_0 {rx_pma_dfe_fixed_taps} {3}
	set_instance_parameter_value xcvr_native_a10_0 {rx_pma_div_clkout_divider} {0}
	set_instance_parameter_value xcvr_native_a10_0 {rx_ppm_detect_threshold} {1000}
	set_instance_parameter_value xcvr_native_a10_0 {set_capability_reg_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_cdr_refclk_freq} {644.531250}
	set_instance_parameter_value xcvr_native_a10_0 {set_csr_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_data_rate} {10312.5}
	set_instance_parameter_value xcvr_native_a10_0 {set_disconnect_analog_resets} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_embedded_debug_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_enable_calibration} {1}
	set_instance_parameter_value xcvr_native_a10_0 {set_hip_cal_en} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_odi_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_pcs_bonding_master} {Auto}
	set_instance_parameter_value xcvr_native_a10_0 {set_prbs_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_rcfg_emb_strm_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {set_user_identifier} {0}
	set_instance_parameter_value xcvr_native_a10_0 {sim_reduced_counters} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_data_mask_count_multi} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_low_latency_bypass_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_pcs_pma_width} {10}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_8b10b_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_bitrev_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_byte_deser_mode} {Disabled}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_byterev_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_pcfifo_mode} {low_latency}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_rmfifo_mode} {disabled}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_rmfifo_pattern_n} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_rmfifo_pattern_p} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_fast_sync_status_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_mode} {bitslip}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_pattern} {0.0}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_pattern_len} {7}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_renumber} {3}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_rgnumber} {3}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_rknumber} {3}
	set_instance_parameter_value xcvr_native_a10_0 {std_rx_word_aligner_rvnumber} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_8b10b_disp_ctrl_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_8b10b_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_bitrev_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_bitslip_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_byte_ser_mode} {Disabled}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_byterev_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_pcfifo_mode} {low_latency}
	set_instance_parameter_value xcvr_native_a10_0 {std_tx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_a10_0 {support_mode} {user_mode}
	set_instance_parameter_value xcvr_native_a10_0 {tx_pma_clk_div} {1}
	set_instance_parameter_value xcvr_native_a10_0 {tx_pma_div_clkout_divider} {33}
	set_instance_parameter_value xcvr_native_a10_0 {validation_rule_select} {}
	set_instance_property xcvr_native_a10_0 AUTO_EXPORT true

	# add wirelevel expressions

	# preserve ports for debug

	# add the exports
	set_interface_property tx_analogreset EXPORT_OF xcvr_native_a10_0.tx_analogreset
	set_interface_property tx_digitalreset EXPORT_OF xcvr_native_a10_0.tx_digitalreset
	set_interface_property rx_analogreset EXPORT_OF xcvr_native_a10_0.rx_analogreset
	set_interface_property rx_digitalreset EXPORT_OF xcvr_native_a10_0.rx_digitalreset
	set_interface_property tx_cal_busy EXPORT_OF xcvr_native_a10_0.tx_cal_busy
	set_interface_property rx_cal_busy EXPORT_OF xcvr_native_a10_0.rx_cal_busy
	set_interface_property tx_serial_clk0 EXPORT_OF xcvr_native_a10_0.tx_serial_clk0
	set_interface_property rx_cdr_refclk0 EXPORT_OF xcvr_native_a10_0.rx_cdr_refclk0
	set_interface_property tx_serial_data EXPORT_OF xcvr_native_a10_0.tx_serial_data
	set_interface_property rx_serial_data EXPORT_OF xcvr_native_a10_0.rx_serial_data
	set_interface_property rx_set_locktodata EXPORT_OF xcvr_native_a10_0.rx_set_locktodata
	set_interface_property rx_set_locktoref EXPORT_OF xcvr_native_a10_0.rx_set_locktoref
	set_interface_property rx_is_lockedtoref EXPORT_OF xcvr_native_a10_0.rx_is_lockedtoref
	set_interface_property rx_is_lockedtodata EXPORT_OF xcvr_native_a10_0.rx_is_lockedtodata
	set_interface_property tx_coreclkin EXPORT_OF xcvr_native_a10_0.tx_coreclkin
	set_interface_property rx_coreclkin EXPORT_OF xcvr_native_a10_0.rx_coreclkin
	set_interface_property tx_clkout EXPORT_OF xcvr_native_a10_0.tx_clkout
	set_interface_property rx_clkout EXPORT_OF xcvr_native_a10_0.rx_clkout
	set_interface_property tx_parallel_data EXPORT_OF xcvr_native_a10_0.tx_parallel_data
	set_interface_property unused_tx_parallel_data EXPORT_OF xcvr_native_a10_0.unused_tx_parallel_data
	set_interface_property rx_parallel_data EXPORT_OF xcvr_native_a10_0.rx_parallel_data
	set_interface_property unused_rx_parallel_data EXPORT_OF xcvr_native_a10_0.unused_rx_parallel_data

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="xcvr_native_a10_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {trans.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {trans}

	# save the system
	sync_sysinfo_parameters
	save_system trans
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_trans

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
