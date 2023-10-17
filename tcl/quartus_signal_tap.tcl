
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
set_global_assignment -name ENABLE_SIGNALTAP ON
set_global_assignment -name USE_SIGNALTAP_FILE xcvr_dbg.stp
set_global_assignment -name SIGNALTAP_FILE output_files/stp_debug.stp

set_global_assignment -name SDC_FILE system.sdc
set_global_assignment -name SIGNALTAP_FILE output_files/stp1.stp

