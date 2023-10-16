# set global assigmenent wrapper
proc sga_wrap {var val} {
	set ret [set_global_assignment -name $var $val]
	if {$ret != 0} {
		puts "Error: assigning $var to $val, code $ret"
	} 
}
