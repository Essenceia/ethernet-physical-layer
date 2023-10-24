load_package ::quartus::project
load_package ::quartus::sdc_ext

source utils.tcl

set project_name "PCS"

set npaths 10

set fname $project_name/sta_report.txt


# Open project
project_open $project_name 

# create timing netlist
create_timing_netlist

# target SDC file will have been configured at setup
read_sdc

update_timing_netlist

check_timing -file $fname
 
report_timing -npaths $npaths -nworst 100 -show_routing -append -file $fname

#report_timing -nworst $npaths -delay_type max -sort_by group -file $fname                 

# Close project
project_close
