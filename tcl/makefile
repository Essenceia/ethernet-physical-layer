# TCL makefile, used to automatise clean as overwrite functionality
# fails on quartus projects that have been build with an error

PROJECT=PCS
PROJECT_DIR=$(PROJECT)
PROJECT_FILE=$(PROJECT).qpf

LANG=VERILOG
QUARTUS_TCL=quartus_sh -t

RTL_DIR=..
FPGA_DIR=../cy10gx

# Compatibility mode : rework ip generation tcl files
ifndef compat
compat:=
endif

.PHONY: build setup lint synth place
########
# Init #
########
# init project
init:quartus_init.tcl
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
	$(if $(compat),$(info Compatibility mode dissabled),./clean_ip_tcl.sh $1.tcl)
	qsys-script --script=$$< $(QSYS_ARGS)
	qsys-generate $$@.ip --synthesis=$(LANG) $(QSYS_ARGS)

endef

# ip list
ip_list := trans qsfp_trans phy_rst atxpll cdc_fifo pcs_core_fpll

$(eval $(foreach x,$(ip_list),$(call IP_GEN,$x)))

###########
# Project #
###########

bsp_deps:= $(FPGA_DIR)/bsp_lite.tcl timing.sdc
 
# setup project files and IP
setup:quartus_setup.tcl $(bsp_deps) $(PROJECT_FILE) $(ip_list)
	$(QUARTUS_TCL) $<

# lint
# call lint when ip files are modified or when
# verilog files are modified
rtl_deps = $(shell ls $(RTL_DIR)/*.v) $(FPGA_DIR)/top.v 


lint:quartus_lint.tcl setup $(rtl_deps) 
	$(QUARTUS_TCL) $<

# synth
synth:
	quartus_syn $(PROJECT)

# place and route
place:
	quartus_fit $(PROJECT)

timing: quartus_timing.tcl
	quartus_sta -t $<

assemble:
	quartus_asm $(PROJECT)

tap:
	quartus_stp $(PROJECT) 	

build:
	$(MAKE) init	
	$(MAKE) setup
	$(MAKE) rebuild_timing
	$(MAKE) assemble

rebuild_timing:
	$(MAKE) synth
	$(MAKE) place
	$(MAKE) timing

# clean
clean:
	rm -rf db
	rm -rf dni
	rm -rf DNI
	rm -rf .qsys_edit
	rm -rf tmp-clearbox
	$(foreach x,$(ip_list),$(call IP_CLEAN,$x))
	rm -rf qdb
	rm -f $(PROJECT).*
	rm -r $(PROJECT)
	rm -rf pcs
	rm -f serv_req_info.txt
