load_package ::quartus::project

# Setup PCS project for quartus

set project_name "PCS"

set fpga_family "Cyclone 10 GX"

set fpga_part "10CX150YF780"

set project_dir "quartus_test"

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY $project_dir

# project configuration
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"

# create new quartus project
project_new -family $fpga_family -overwrite -part $fpga_part $project_name
