# TCL makefile, used to automatise clean as overwrite functionality
# fails on quartus projects that have been build with an error

PROJECT=PCS
LANG=VERILOG
######
# IP #
######

QSYS_ARGS:= --quartus-project=$(PROJECT).qpf

# Clean existing ip file and generate new IP instance
define IP_CLEAN
	rm -fr $1
	rm -f $1.qdf
	rm -f $1.qpf
endef
define IP_GEN
$(info IP_GEN called on $(1))
$1: $1.tcl
	$$(call IP_CLEAN,$$@)
	qsys-script --script=$$< $(QSYS_ARGS)
	qsys-generate $$@.ip --synthesis=$(LANG) $(QSYS_ARGS)
endef

# ip list
ip_list := phase_align_fpll

$(eval $(foreach x,$(ip_list),$(call IP_GEN,$x)))

$(info ip_list $(ip_list))
clean:
	yes | rm -r db
	$(eval $(foreach x,$(ip_list),$(call IP_CLEAN,$x)))
	rm -f PCS.*
