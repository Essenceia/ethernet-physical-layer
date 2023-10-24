load_package ::quartus::project
load_package ::quartus::flow

source utils.tcl

# Setup PCS project for quartus

set project_name "PCS"

set fpga_family "Cyclone 10 GX"

set project_dir $project_name

set fpga_device 10CX150YF780E5G


# create new quartus project
project_new $project_name -overwrite

# set fpga
set_global_assignment -name FAMILY $fpga_family
set_global_assignment -name DEVICE $fpga_device

# project configuration
set_global_assignment -name OPTIMIZATION_MODE "BALANCED"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY $project_dir

set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2009
set_global_assignment -name ADD_PASS_THROUGH_LOGIC_TO_INFERRED_RAMS ON
set_global_assignment -name VERILOG_MACRO QUARTUS
set_global_assignment -name VERILOG_MACRO SYNTHESIS

#close
project_close
