load_package ::quartus::project
load_package ::quartus::flow

source utils.tcl

set project_name "PCS"

# Open project
project_open $project_name.qpf 

# parse files and report lint errors
execute_flow -compile

# Close project
project_close
