# Custom board pin assignement
# Lite version : only strictly needed pins

set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 780
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1

#[Transceiver Ref Clocks]
set_location_assignment PIN_R24 -to GXB1D_125M
set_location_assignment PIN_N24 -to GXB1D_644M
set_instance_assignment -name IO_STANDARD LVDS -to GXB1D_125M -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD LVDS -to GXB1D_644M -entity c10gx_pinout
set_location_assignment PIN_R23 -to "GXB1D_125M(n)"
set_location_assignment PIN_N23 -to "GXB1D_644M(n)"

#[Transceiver Lanes (Bank 1D)]
set_location_assignment PIN_F26 -to SFP1_RXD
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to SFP1_RXD -entity c10gx_pinout
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to SFP1_RXD -entity c10gx_pinout
set_location_assignment PIN_F25 -to "SFP1_RXD(n)"

set_location_assignment PIN_G28 -to SFP1_TXD
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to SFP1_TXD -entity c10gx_pinout
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to SFP1_TXD -entity c10gx_pinout
set_location_assignment PIN_G27 -to "SFP1_TXD(n)"

#[3.0V I/O]
set_location_assignment PIN_A24 -to OSC_50m
set_instance_assignment -name IO_STANDARD "1.8 V" -to OSC_50m -entity c10gx_pinout

set_location_assignment PIN_E22 -to FPGA_RSTn
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to FPGA_RSTn -entity c10gx_pinout

