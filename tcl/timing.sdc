# Timing and clock information
set_time_format -unit ns -decimal_places 8


# External clock sources

# 50 MHz oscillator
create_clock -period 20 [get_ports OSC_50m] 

# 644,53125 MHz oscillator on transiver bank 1D
create_clock -period 1.55151515 [get_ports GXB1D_644M] 

# 125 MHz oscillator on transiver bank 1D
create_clock -period 8.0 [get_ports GXB1D_125M]   
