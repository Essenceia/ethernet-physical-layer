# set global assigmenent wrapper
proc sga_wrap {var val} {
	set ret [set_global_assignment -name $var $val]
	if {$ret != 0} {
		puts "Error: assigning $var to $val, code $ret"
	} 
}

proc readports { regex } {
set ports [get_ports $regex]
foreach_in_collection port $ports {
    puts [get_port_info -name $port]
}
}

proc readregs { regex } {
set regs [get_registers $regex ]
foreach_in_collection reg $regs {
    puts [get_object_info -name $reg]
}
}

proc readclocks { regex } {
	set regs [get_clocks $regex ]
	foreach_in_collection reg $regs {
		puts [get_clock_info -name $reg]
	}
}

proc readnodes { regex } {
set nodes [get_nodes $regex]
foreach_in_collection node $nodes {
    puts [get_object_info -name $node]
}
}


proc setup_timing { project_name } {
# Open project
project_open $project_name 

# create timing netlist
create_timing_netlist

# target SDC file will have been configured at setup
read_sdc

update_timing_netlist

}
