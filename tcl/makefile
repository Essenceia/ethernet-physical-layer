# TCL makefile, used to automatise clean as overwrite functionality
# fails on quartus projects that have been build with an error

PROJECT=PCS
PROJECT_FILE=$(PROJECT).qpf
LANG=VERILOG
QUARTUS_TCL=quartus_sh -t

########
# Init #
########
# init project
$(PROJECT_FILE):quartus_init.tcl
	$(QUARTUS_TCL) $<	 

 
######
# IP #
######

QSYS_ARGS:= --quartus-project=$(PROJECT).qpf

# Clean existing ip file and generate new IP instance
define IP_CLEAN
	rm -fr $1
	rm -f $1.ip
	rm -f $1.qdf
	rm -f $1.qpf
endef
define IP_GEN
$1: $1.tcl $(PROJECT_FILE)
	$$(call IP_CLEAN,$$@)
	qsys-script --script=$$< $(QSYS_ARGS)
	qsys-generate $$@.ip --synthesis=$(LANG) $(QSYS_ARGS)

endef

# ip list
ip_list := phase_align_fpll trans phy_rst phyfpll iopll

$(eval $(foreach x,$(ip_list),$(call IP_GEN,$x)))

###########
# Project #
###########

# setup project files and IP
setup_$(PROJECT):quartus_setup.tcl $(ip_list)
	$(QUARTUS_TCL) $<

# lint
# call lint when ip files are modified or when
# verilog files are modified
#rtl_deps := 
#lint_#(PROJECT):quartus_init.tcl 
# synth


clean:
	yes | rm -r db
	$(eval $(foreach x,$(ip_list),$(call IP_CLEAN,$x)))
	rm -f PCS.*
