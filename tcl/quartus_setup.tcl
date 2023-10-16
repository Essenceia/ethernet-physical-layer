load_package ::quartus::project
load_package ::quartus::flow

source utils.tcl

# Setup PCS project for quartus

set project_name "PCS"

set fpga_family "Cyclone 10 GX"

set fpga_device 10CX150YF780E5G

set project_dir "pcs"

set rtl_dir ".."

set fpga_dir "../cy10gx"

# create new quartus project
project_new $project_name -overwrite

# set fpga
set_global_assignment -name FAMILY $fpga_family
set_global_assignment -name DEVICE $fpga_device

# project configuration
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY $project_dir

set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2009
set_global_assignment -name ADD_PASS_THROUGH_LOGIC_TO_INFERRED_RAMS ON
set_global_assignment -name VERILOG_MACRO QUARTUS
set_global_assignment -name VERILOG_MACRO SYNTHESIS

# include project files
# TX
set_global_assignment -name VERILOG_FILE $rtl_dir/_64b66b_tx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/am_lane_tx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/am_tx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/gearbox_tx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/pcs_enc_lite.v
set_global_assignment -name VERILOG_FILE $rtl_dir/pcs_tx.v

#RX
set_global_assignment -name VERILOG_FILE $rtl_dir/_64b66b_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/am_lock_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/block_sync_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/deskew_lane_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/deskew_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/lane_reorder_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/gearbox_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/dec_lite_rx.v
set_global_assignment -name VERILOG_FILE $rtl_dir/pcs_rx.v



#IP

#TOP
set_global_assignment -name VERILOG_FILE $fpga_dir/top.v
# set top
set_global_assignment -name TOP_LEVEL_ENTITY top

# parse files and report lint errors
execute_flow -compile

#close
project_close
