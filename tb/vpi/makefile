
################
# Sanitization #
################

# Disable builtin implicit rules.
.SUFFIXES :
% :: %,v
% :: s.%
% :: RCS/%,v
% :: RCS/%
% :: SCCS/%
% :: SCCS/s.%

############
# Sim type #
############

# Define simulator we are using, priority to iverilog
SIM ?= I
$(info Using simulator: $(SIM))

###########
# Globals #
###########

# AUR Path.
AUR := $(HOME)/AUR

# Compilation flags.
CC_FLAGS := -Wall -Wextra -Wconversion -Wshadow -Wundef -fno-common -Wno-unused-parameter -Wno-type-limits -fpic 
CC_FLAGS += $(if $(debug),-g) 

# Compilation defines.
CC_DEFS := $(if $(debug),-DDEBUG) 
CC_DEFS +=$(if $(40GBASE), -D_40GBASE)

# Link flags.
LD_FLAGS := $(if $(debug),-g) 

# Per-testbench parameters.
ifeq ($(SIM),I)
BUILD=build
CC_CMD=cc
LD_CMD=cc
CC_FLAGS += -std=gnu99

# set vpi lib path when using iverilog :
VPI_INC := -I$(AUR)/iverilog

VPI_DIR := vpi_i
PP :=
else
BUILD=obj_vpi
CC_CMD=g++
LD_CMD=g++
CC_FLAGS += -fpermissive
CC_DEFS += -DVERILATOR
CC_DEFS += $(if $(wave),-DVM_TRACE)

# set vpi lib path when using verilator :
VPI_INC := -I/usr/local/share/verilator/include 
VPI_INC += -I/usr/local/share/verilator/include/vltstd

VPI_INC += -I../../obj_dir
VPI_DIR := vpi_v
PP := pp
endif

# Log.
$(info Using SIM=$(SIM), building to $(BUILD) dir)

# Compilation utils.
CC := $(CC_CMD) $(CC_FLAGS) $(CC_DEFS)
LD := $(LD_CMD) $(LD_FLAGS)  

###########
# Headers #
###########

# All headers that are accessible to .c/cpp files.
# Any change in those will cause any required .o file to be rebuilt.
HDRS := pcs_gearbox.h pcs_defs.h pcs_enc.h pcs_marker.h pcs_tx.h
HDRS += 64b66b.h
HDRS += tb_rand.h tb_fifo.h tb_utils.h 
HDRS += tb_pcs_common.h tb_marker_common.h
HDRS += tv.h
HDRS += $(VPI_DIR)/tb_marker.h$(PP)
HDRS += $(VPI_DIR)/tb_pcs.h$(PP)

#########
# Build #
#########

# General sources
SRCS := test
SRCS += pcs_gearbox pcs_enc pcs_marker pcs_tx
SRCS += tb_rand tb_fifo tb_utils
SRCS += tb_marker_common tb_pcs_common
SRCS += 64b66b
SRCS += tv

# VPI sources
VPI_SRCS := tb_marker
VPI_SRCS += tb_pcs

# Standard object file build recipe.
define obj_recipe
$$(BUILD)/$1.o:$1.c $(HDRS)
	@mkdir -p $$(@D)
	$$(CC) $$(VPI_INC) -o $$@ -c $1.c

endef

# VPI object file build recipe.
define vpi_obj_recipe
$$(BUILD)/$1.o: $$(VPI_DIR)/$1.c$(PP) $$(HDRS)
	@mkdir -p $$(@D)
	$$(CC) $$(VPI_INC) -o $$@ -c $$(VPI_DIR)/$1.c$$(PP)

endef

# Generate run recipes for each testbench.
$(eval $(foreach x,$(SRCS),$(call obj_recipe,$x)))
$(eval $(foreach x,$(VPI_SRCS),$(call vpi_obj_recipe,$x)))

################
# Dependencies #
################

# Dependencies for all tests. '.o'-s ommitted.
40g_deps := $(if $(40GBASE),pcs_marker)
deps_all := tv pcs_gearbox pcs_enc 64b66b pcs_tx tb_fifo tb_rand $(40g_deps)

# Test dependencies names. '.o'-s ommitted.
test_deps_names := test $(deps_all) 
tb_deps_names := tb_pcs tb_pcs_common tb_utils $(deps_all)
tb_marker_deps_names := tb_marker tb_utils tb_marker_common tb_rand pcs_marker

# Dependencies generator.
gen_deps = $(foreach x,$($(1)_deps_names),$(BUILD)/$x.o)

# Dependencies.
test_deps := $(call gen_deps,test)
tb_deps := $(call gen_deps,tb)
tb_marker_deps := $(call gen_deps,tb_marker)

###########
# Targets #
###########

test: $(test_deps)
	$(LD) -o test -g $^

$(BUILD)/tb_all.o: $(tb_deps)
	@mkdir -p $(@D)
	$(LD) -r -o $(BUILD)/tb_all.o $^

$(BUILD)/tb.vpi: $(BUILD)/tb_all.o
	@mkdir -p $(@D)
	$(LD) -shared -o $(BUILD)/tb.vpi $^ -lvpi

$(BUILD)/tb_marker_all.o: $(tb_marker_deps)
	@mkdir -p $(@D)
	$(LD) -r -o $(BUILD)/tb_marker_all.o $^

$(BUILD)/tb_marker.vpi: $(BUILD)/tb_marker_all.o
	@mkdir -p $(@D)
	$(LD) -shared -o $(BUILD)/tb_marker.vpi $^ -lvpi

####################
# Standard targets #
####################

clean:
	rm -rf build/*	
	rm -rf obj_vpi/*	
	rm -f test	
	rm -f vgcore.*	

