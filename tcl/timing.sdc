# Timing and clock information

# would like to put 8 decimal places but 3 is the maximum
set_time_format -unit ns -decimal_places 3


# External clock sources

# 50 MHz oscillator
create_clock -period 20 [get_ports OSC_50m] 

# 644,53125 MHz oscillator on transiver bank 1D
create_clock -period 1.551 [get_ports GXB1D_644M] 

# 125 MHz oscillator on transiver bank 1D
create_clock -period 8.0 [get_ports GXB1D_125M]  

# nreset 2ff sync
set_false_path -from [get_registers gx_nreset] -to [get_registers nreset_next]

# User contrained generate clocks : for PLLs
# ATX -> tx transiver
derive_pll_clocks

# rx -> tx, data and reset
set_false_path -from [get_registers m_pcs_loopback|pcs_rx*] \
-to [get_registers m_pcs_loopback|pcs_tx*] 

# User contrained clock uncertainty
derive_clock_uncertainty 
