# TCL makefile, used to automatise clean as overwrite functionality
# fails on quartus projects that have been build with an error

PROJECT=PCS
PROJECT_FILE=$(PROJECT).qpf
LANG=VERILOG
QUARTUS_TCL=quartus_sh -t

RTL_DIR=..
FPGA_DIR=../cy10gx

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
	./clean_ip_tcl.sh $1.tcl
	qsys-script --script=$$< $(QSYS_ARGS)
	qsys-generate $$@.ip --synthesis=$(LANG) $(QSYS_ARGS)

endef

# ip list
#ip_list := phase_align_fpll trans phy_rst phyfpll iopll
ip_list := trans phy_rst phyfpll

$(eval $(foreach x,$(ip_list),$(call IP_GEN,$x)))

###########
# Project #
###########

bsp_deps:= $(FPGA_DIR)/bsp_lite.tcl timing.sdc
 
# setup project files and IP
setup_$(PROJECT):quartus_setup.tcl $(bsp_deps) $(PROJECT_FILE) $(ip_list)
	$(QUARTUS_TCL) $<

# lint
# call lint when ip files are modified or when
# verilog files are modified
rtl_deps = $(shell ls $(RTL_DIR)/*.v) $(FPGA_DIR)/top.v 

lint_$(PROJECT):quartus_lint.tcl setup_$(PROJECT) $(rtl_deps) 
	$(QUARTUS_TCL) $<

# synth

# place and route
place_$(PROJECT):quartus_place.tcl lint_$(PROJECT) 
	$(QUARTUS_TCL) $<



# clean
clean:
	rm -rf db
	rm -rf tmp-clearbox
	$(foreach x,$(ip_list),$(call IP_CLEAN,$x))
	rm -rf qdb
	rm -f PCS.*
	rm -f serv_req_info.txt
