load_package ::quartus::project
load_package ::quartus::flow

source utils.tcl

set project_name "PCS"

# Open project
project_open $project_name.qpf 


#quartus_syn --analysis_and_elaboration 

# Check IO
#execute_flow -check_ios

# Check netlist
#execute_flow -check_netlist

# Place and route and dump databse
#execute_flow -compile -export_database

# TODO wip
execute_flow -compile
execute_flow -export_database

# Close project
project_close
