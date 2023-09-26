load_package ::quartus::project

# Setup PCS project for quartus

set project_name "PCS"

set fpga_family "Cyclone 10 GX"

set fpga_device 10CX150YF780E5G

set project_dir "quartus_test"


# create new quartus project
project_new $project_name -overwrite

# set decide
set_global_assignment -name FAMILY $fpga_family
set_global_assignment -name DEVICE $fpga_device

# project configuration
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY $project_dir


