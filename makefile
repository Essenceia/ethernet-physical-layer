
###########
# Configs #
###########

ifndef debug
#debug :=
endif

# Enable waves by default
ifndef wave
wave:=1
endif

# Dissable coverage by default
ifndef cov
cov:=
endif

# Asserts, enabled by default
ifndef assert
assert:=1
endif

# Wip, bypass some lint flags, dissabled by default
ifndef wip
wip:=
endif


############
# Sim type #
############

# Define simulator we are using, priority to iverilog
SIM ?= I
$(info Using simulator: $(SIM))

###########
# Globals #
###########

# Global configs.
TB_DIR := tb
VPI_DIR := $(TB_DIR)/vpi
CONF := conf
WAVE_FILE := wave.vcd
WAVE_DIR := wave
VIEW := gtkwave
WAVE_CONF := wave.conf
GDB_CONF := .gdbinit
DEBUG_FLAG := $(if $(debug), debug=1)
DEFINES := $(DEBUG_FLAG) $(if $(40GBASE), 40GBASE=1) $(if $(wave),wave=1)
40GBASE_ARGS:= 40GBASE=1

HW_DIR := cy10gx

# Current working directory.
CWD := $(shell pwd)

########
# Lint #
########

# Lint variables.
LINT_FLAGS :=
LINT_FLAGS += $(if $(debug),-DDEBUG) 
ifeq ($(SIM),I)
LINT_FLAGS += -Wall -g2012 $(if $(assert),-gassertions) -gstrict-expr-width
else
LINT_FLAGS += -Wall -Wpedantic
LINT_FLAGS += $(if $(wip),-Wno-latch -Wno-unusedsignal)
endif

# Lint commands.
# TODO ONELINER
ifeq ($(SIM),I)
define LINT
	iverilog $(LINT_FLAGS) -s $2 -o $(BUILD_DIR)/$2 $1
endef
else
define LINT
	verilator --lint-only $(LINT_FLAGS) $1
endef
endif

#########
# Build #
#########

# Build variables.
ifeq ($(SIM),I)
BUILD_DIR := build
BUILD_FLAGS := 
else
BUILD_DIR := obj_dir
BUILD_FLAGS := 
BUILD_FLAGS += $(if $(assert),--assert)
BUILD_FLAGS += $(if $(wave), --trace --trace-underscore) 
BUILD_FLAGS += $(if $(cov), --coverage --coverage-underscore) 
BUILD_FLAGS += --timing
BUILD_FLAGS += --x-initial-edge
MAKE_THREADS = 4 
BUILD_FLAGS += -j $(MAKE_THREADS)
endif

# Build commands.
ifeq ($(SIM),I)
define BUILD
	iverilog $(LINT_FLAGS) -s $2 -o $(BUILD_DIR)/$2 $1
endef
else
define BUILD
	verilator --binary $(LINT_FLAGS) $(BUILD_FLAGS) -o $2 $1  
endef
endif

#############
# VPI build #
#############

# VPU Build variables
ifeq ($(SIM),I)
BUILD_VPI_DIR := build
else
BUILD_VPI_DIR := obj_vpi
endif

# VPI build commands.
ifeq ($(SIM),I)
define BUILD_VPI
	# Manually invoke vpi to not polute dependancy list
	@$(MAKE) -f makefile $3
	# Same as normal build
	iverilog $(LINT_FLAGS) -s $2 -o $(BUILD_DIR)/$2 $1
endef
else
define BUILD_VPI
	@printf "\nVerilating vpi design and tb \n\n"
	verilator -cc --exe --vpi --public-flat-rw --threads 1 $(LINT_FLAGS) $(BUILD_FLAGS) --top-module $2 -LDFLAGS "$(CWD)/$(VPI_DIR)/$(BUILD_VPI_DIR)/$4_all.o V$2__ALL.a" -o $2 $1
	
	@printf "\nMaking vpi shared object \n\n"
	@$(MAKE) -f makefile $3
	
	@printf "\nInvoking generated makefile \n\n"
	$(MAKE) -C $(BUILD_DIR) -j $(MAKE_THREADS) -f V$2.mk
endef
endif

#######
# Run #
#######

# Run commands.
ifeq ($(SIM),I)
define RUN
	vvp $(BUILD_DIR)/$1
endef
define RUN_VPI
	vvp -M $(VPI_DIR)/$(BUILD_VPI_DIR) -mtb $(BUILD_DIR)/$1
endef
else
define RUN
	./$(BUILD_DIR)/$1 $(if $(wave),+trace) 
endef
define RUN_VPI
	$(call RUN,$1)
endef
endif

config:
	@mkdir -p $(CONF)

build:
	@mkdir -p $(BUILD_DIR)

########
# Lint #
########

# Dependencies for linter.
pcs_tx_deps := pcs_tx.v pcs_enc_lite.v _64b66b_tx.v gearbox_tx.v am_tx.v am_lane_tx.v  
pcs_rx_deps := pcs_rx.v gearbox_rx.v block_sync_rx.v am_lock_rx.v lane_reorder_rx.v deskew_rx.v deskew_lane_rx.v _64b66b_rx.v dec_lite_rx.v 
fake_reset_deps := fake_reset.v 

lint_64b66b_tx : _64b66b_tx.v build
	$(call LINT, _64b66b_tx.v, $64b66b_tx)

lint_64b66b_rx : _64b66b_rx.v build
	$(call LINT, _64b66b_rx.v,$,64b66b_rx)

lint_pcs_tx : $(pcs_tx_deps)
	$(call LINT, $(pcs_tx_deps),pcs_tx)

lint_pcs_rx: $(pcs_rx_deps)
	$(call LINT, $(pcs_rx_deps),pcs_rx)

lint_fake_reset: $(fake_reset_deps)
	$(call LINT,$(fake_reset_deps),fake_reset)

#############
# Testbench #
#############

# The list of testbenches.
tbs := _64b66b gearbox_tx gearbox_rx block_sync_rx am_lock_rx lane_reorder_rx xgmii_dec_rx deskew_rx
tbs += pcs_10g_loopback

# Standard run recipe to build a given testbench
define build_recipe
$1_tb: $$($(1)_deps)
	$$(call BUILD,$$^,$$@)

endef

# Dependencies for each testbench
# TODO the pattern $(TB_DIR)/$(TB_NAME)_tb.sv can be optimized, if _64b66b_tb.v -> _64b66b_tb.sv is ok.
_64b66b_deps := _64b66b_tx.v _64b66b_rx.v $(TB_DIR)/_64b66b_tb.sv
gearbox_tx_deps := gearbox_tx.v $(TB_DIR)/gearbox_tx_tb.sv
gearbox_rx_deps := gearbox_rx.v $(TB_DIR)/gearbox_rx_tb.sv
block_sync_rx_deps := block_sync_rx.v $(TB_DIR)/block_sync_rx_tb.sv 
am_lock_rx_deps := am_lock_rx.v $(TB_DIR)/am_lock_rx_tb.sv 
lane_reorder_rx_deps := lane_reorder_rx.v $(TB_DIR)/lane_reorder_rx_tb.sv 
xgmii_dec_rx_deps := dec_lite_rx.v xgmii_dec_intf_rx.v $(TB_DIR)/xgmii_dec_rx_tb.sv 
deskew_rx_deps := deskew_rx.v deskew_lane_rx.v $(TB_DIR)/deskew_rx_tb.sv 
pcs_10g_loopback_deps :=  pcs_10g_loopback.v $(pcs_rx_deps) $(pcs_tx_deps) $(TB_DIR)/pcs_10g_loopback_tb.sv 
# Standard run recipe to run a given testbench
define run_recipe
run_$1: $1_tb
	$$(call RUN,$$^)

endef

# Generate run recipes for each testbench.
$(eval $(foreach x,$(tbs),$(call run_recipe,$x)))


# Generate build recipes for each testbench.
$(eval $(foreach x,$(tbs),$(call build_recipe,$x)))


#################
# VPI testbench #
#################

pcs_tb : $(TB_DIR)/pcs_tb.sv $(pcs_tx_deps) $(pcs_rx_deps) 
	$(call BUILD_VPI,$^,$@,vpi,tb)

# VPI Test bench 
am_tx_tb :  am_tx.v am_lane_tx.v $(TB_DIR)/am_tx_tb.sv 
	$(call BUILD_VPI,$^,$@,vpi_marker,tb_marker)

# Run VPI
run_pcs_cmd := vvp -M $(VPI_DIR)/$(BUILD_VPI_DIR) -mtb $(BUILD_DIR)/pcs_tb
run_pcs: pcs_tb
	$(call RUN_VPI,$^)

run_am_tx: am_tx_tb 
	cp $(VPI_DIR)/$(BUILD_VPI_DIR)/tb_marker.vpi $(VPI_DIR)/$(BUILD_VPI_DIR)/tb.vpi
	$(call RUN_VPI,$^)

vpi:
	cd $(VPI_DIR) && $(MAKE) $(BUILD_VPI_DIR)/tb.vpi SIM=$(SIM) $(DEFINES) $(40GBASE_ARGS)

vpi_marker:
	cd $(VPI_DIR) && $(MAKE) $(BUILD_VPI_DIR)/tb_marker.vpi SIM=$(SIM) $(DEFINES) $(40GBASE_ARGS)

wave: config
	$(VIEW) $(WAVE_DIR)/$(WAVE_FILE) $(CONF)/$(WAVE_CONF)

#################
# HW testbench  #
#################

	
#################
# Debug targets #
#################

debug_run:= $(call RUN_VPI,pcs_tb)

valgrind: 
	valgrind $(debug_run)

valgrind2: pcs_tb vpi
	valgrind --leak-check=full --show-leak-kinds=all --fullpath-after=. $(debug_run) 

profile: pcs_tb vpi
	valgrind --tool=callgrind $(debug_run)

gdb: pcs_tb vpi
	gdb -x $(CONF)/$(GDB_CONF) --args $(debug_run)

####################
# Standard targets #
####################

# Cleanup
clean:
	cd $(VPI_DIR) && $(MAKE) clean
	rm -f vgcore.* vgd.log*
	rm -f callgrind.out.*
	rm -fr build/*
	rm -fr obj_dir/*
	rm -fr $(WAVE_DIR)/*

# Run
run: run_pcs

# Default.
all: run wave
	
