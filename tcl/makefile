# TCL makefile, used to automatise clean as overwrite functionality
# fails on quartus projects that have been build with an error

######
# IP #
######

# Clean existing ip file and generate new IP instance
define IP_CLEAN
	rm -fr $1
	rm -fr $1.qdf
endef
define IP_GEN
$(info IP_GEN called on $1)
$1: $1.tcl
	$(call IP_CLEAN,$1)
	qsys-script --script=$<
endef

# ip list
ip_list := phase_align_fpll

$(eval $(foreach,x,$(ip_list),$(call IP_GEN,$x)))

clean:
	yes | rm -r db
	$(eval $(foreach,x,$(ip_list),$(call IP_CLEAN,$x)))
	rm -f PCS.*
