# Custom board pin assignement
# Lite version : only strictly needed pins

set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 780
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1

#[Transceiver Ref Clocks]
set_location_assignment PIN_R24 -to GXB1D_125M
set_location_assignment PIN_N24 -to GXB1D_644M
set_location_assignment PIN_R23 -to "GXB1D_125M_N"
set_location_assignment PIN_N23 -to "GXB1D_644M_N"
set_instance_assignment -name IO_STANDARD LVDS -to GXB1D_125M -entity top
set_instance_assignment -name IO_STANDARD LVDS -to GXB1D_644M -entity top

#[Transceiver Lanes (Bank 1D)]
set_location_assignment PIN_P26 -to GXB1D_RXD[0]
set_location_assignment PIN_M26 -to GXB1D_RXD[1]
set_location_assignment PIN_K26 -to GXB1D_RXD[2]
set_location_assignment PIN_H26 -to GXB1D_RXD[3]
set_location_assignment PIN_F26 -to GXB1D_RXD[4]
set_location_assignment PIN_D26 -to GXB1D_RXD[5]
set_location_assignment PIN_D25 -to "GXB1D_RXD_N[5]"
set_location_assignment PIN_F25 -to "GXB1D_RXD_N[4]"
set_location_assignment PIN_H25 -to "GXB1D_RXD_N[3]"
set_location_assignment PIN_K25 -to "GXB1D_RXD_N[2]"
set_location_assignment PIN_M25 -to "GXB1D_RXD_N[1]"
set_location_assignment PIN_P25 -to "GXB1D_RXD_N[0]"
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to GXB1D_RXD[*] -entity top
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to GXB1D_TXD[0] -entity top

set_location_assignment PIN_N28 -to GXB1D_TXD[1]
set_location_assignment PIN_L28 -to GXB1D_TXD[2]
set_location_assignment PIN_J28 -to GXB1D_TXD[3]
set_location_assignment PIN_G28 -to GXB1D_TXD[4]
set_location_assignment PIN_E28 -to GXB1D_TXD[5]
set_location_assignment PIN_E27 -to "GXB1D_TXD_N[5]"
set_location_assignment PIN_G27 -to "GXB1D_TXD_N[4]"
set_location_assignment PIN_J27 -to "GXB1D_TXD_N[3]"
set_location_assignment PIN_L27 -to "GXB1D_TXD_N[2]"
set_location_assignment PIN_N27 -to "GXB1D_TXD_N[1]"
set_location_assignment PIN_R27 -to "GXB1D_TXD_N[0]"
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to GXB1D_TXD[*] -entity top
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to GXB1D_TXD[*] -entity top

#[3.0V I/O]
set_location_assignment PIN_A24 -to OSC_50m
set_instance_assignment -name IO_STANDARD "1.8 V" -to OSC_50m -entity top

set_location_assignment PIN_E22 -to FPGA_RSTn
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to FPGA_RSTn -entity top

# Unusued 

# GX 1D channels [0:3] and 5
set_global_assignment -name PRESERVE_UNUSED_XCVR_CHANNEL ON

# Thermal
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL

export_assignments
