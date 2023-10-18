load_package ::quartus::project

source utils.tcl

set project_name "PCS"

set project_dir "pcs"

set rtl_dir ".."

set fpga_dir "../cy10gx"

# Open project
project_open $project_name.qpf 

# setup pin assignements
source $fpga_dir/bsp_lite.tcl
# setup timing constraints
set_global_assignment -name SDC_FILE timing.sdc

# Commit assignments
export_assignments

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
# ip files should already be included in project by the qsys tcl generation
# expected to be detecting in the Platform Deisgner IP file generation dir

#TOP
set_global_assignment -name VERILOG_FILE $fpga_dir/top.v
# set top
set_global_assignment -name TOP_LEVEL_ENTITY top

#close
project_close
