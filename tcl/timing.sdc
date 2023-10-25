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
set_false_path -from [get_clocks OSC_50m] -to [get_clocks *rx_clkout]
# rx -> tx data
set_false_path -from [get_clocks *rx_clkout] -to [get_clocks *tx_clkout]

# User contrained generate clocks : for PLLs
# ATX -> tx transiver
derive_pll_clocks

# User contrained clock uncertainty
derive_clock_uncertainty 
