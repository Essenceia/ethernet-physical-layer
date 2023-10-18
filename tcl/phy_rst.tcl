package require qsys

# create the system "phy_rst"
proc do_create_phy_rst {} {
	# create the system
	create_system phy_rst
	
	set_project_property DEVICE {10CX150YF780E5G}
	set_project_property DEVICE_FAMILY {Cyclone 10 GX}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance xcvr_reset_control_0 altera_xcvr_reset_control 19.1.1
	set_instance_parameter_value xcvr_reset_control_0 {CHANNELS} {1}
	set_instance_parameter_value xcvr_reset_control_0 {PLLS} {1}
	set_instance_parameter_value xcvr_reset_control_0 {REDUCED_SIM_TIME} {1}
	set_instance_parameter_value xcvr_reset_control_0 {RX_ENABLE} {1}
	set_instance_parameter_value xcvr_reset_control_0 {RX_PER_CHANNEL} {0}
	set_instance_parameter_value xcvr_reset_control_0 {SYNCHRONIZE_PLL_RESET} {0}
	set_instance_parameter_value xcvr_reset_control_0 {SYNCHRONIZE_RESET} {1}
	set_instance_parameter_value xcvr_reset_control_0 {SYS_CLK_IN_MHZ} {50}
	set_instance_parameter_value xcvr_reset_control_0 {TX_ENABLE} {1}
	set_instance_parameter_value xcvr_reset_control_0 {TX_PER_CHANNEL} {0}
	set_instance_parameter_value xcvr_reset_control_0 {TX_PLL_ENABLE} {1}
	set_instance_parameter_value xcvr_reset_control_0 {T_PLL_LOCK_HYST} {0}
	set_instance_parameter_value xcvr_reset_control_0 {T_PLL_POWERDOWN} {1000}
	set_instance_parameter_value xcvr_reset_control_0 {T_RX_ANALOGRESET} {40}
	set_instance_parameter_value xcvr_reset_control_0 {T_RX_DIGITALRESET} {4000}
	set_instance_parameter_value xcvr_reset_control_0 {T_TX_ANALOGRESET} {0}
	set_instance_parameter_value xcvr_reset_control_0 {T_TX_DIGITALRESET} {20}
	set_instance_parameter_value xcvr_reset_control_0 {gui_pll_cal_busy} {0}
	set_instance_parameter_value xcvr_reset_control_0 {gui_rx_auto_reset} {0}
	set_instance_parameter_value xcvr_reset_control_0 {gui_split_interfaces} {1}
	set_instance_parameter_value xcvr_reset_control_0 {gui_tx_auto_reset} {0}
	set_instance_property xcvr_reset_control_0 AUTO_EXPORT true

	# add wirelevel expressions

	# preserve ports for debug

	# add the exports
	set_interface_property clock EXPORT_OF xcvr_reset_control_0.clock
	set_interface_property reset EXPORT_OF xcvr_reset_control_0.reset
	set_interface_property pll_powerdown0 EXPORT_OF xcvr_reset_control_0.pll_powerdown0
	set_interface_property tx_analogreset0 EXPORT_OF xcvr_reset_control_0.tx_analogreset0
	set_interface_property tx_digitalreset0 EXPORT_OF xcvr_reset_control_0.tx_digitalreset0
	set_interface_property tx_ready0 EXPORT_OF xcvr_reset_control_0.tx_ready0
	set_interface_property pll_locked0 EXPORT_OF xcvr_reset_control_0.pll_locked0
	set_interface_property pll_select EXPORT_OF xcvr_reset_control_0.pll_select
	set_interface_property tx_cal_busy0 EXPORT_OF xcvr_reset_control_0.tx_cal_busy0
	set_interface_property rx_analogreset0 EXPORT_OF xcvr_reset_control_0.rx_analogreset0
	set_interface_property rx_digitalreset0 EXPORT_OF xcvr_reset_control_0.rx_digitalreset0
	set_interface_property rx_ready0 EXPORT_OF xcvr_reset_control_0.rx_ready0
	set_interface_property rx_is_lockedtodata0 EXPORT_OF xcvr_reset_control_0.rx_is_lockedtodata0
	set_interface_property rx_cal_busy0 EXPORT_OF xcvr_reset_control_0.rx_cal_busy0

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="xcvr_reset_control_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {phy_rst.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {phy_rst}

	# save the system
	sync_sysinfo_parameters
	save_system phy_rst
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_phy_rst

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
