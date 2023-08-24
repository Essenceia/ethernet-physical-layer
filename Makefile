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

# Define simulator we are using, priority to iverilog
ifndef SIM
SIM:=I
endif
$(info Using simulator: $(SIM))

TB_DIR=tb
VPI_DIR=$(TB_DIR)/vpi
CONF=conf
WAVE_FILE=wave.vcd
WAVE_DIR=wave
VIEW=gtkwave
WAVE_CONF=wave.conf
GDB_CONF=.gdbinit
DEBUG_FLAG=$(if $(debug), debug=1)
DEFINES=$(DEBUG_FLAG) $(if $(40GBASE), 40GBASE=1)
40GBASE_ARGS:= 40GBASE=1

all: run wave
BUILD_FLAGS_I=

# Lint flags
FLAGS_I=-Wall -g2012 $(if $(assert),-gassertions) -gstrict-expr-width
FLAGS_I+=$(if $(debug),-DDEBUG) 
FLAGS=$(FLAGS_I)
FLAGS_V=-Wall -Wpedantic -Wno-GENUNNAMED -Wno-LATCH $(if $(assert),--assert)

#Build flags
BUILD_FLAGS_V=$(if $(wave), --trace --trace-underscore) $(if $(cov), --coverage --coverage-underscore) 

BUILD_DIR_I=build
BUILD_DIR_V=obj_dir
BUILD_VPI_DIR_I=build
BUILD_VPI_DIR_V=obj_vpi

# define functions to be used based on the simulator

define LINT_I
	iverilog $(FLAGS_I) -s $2 -o $(BUILD_DIR_I)/$2 $1
endef
define LINT_V
	verilator --lint-only $(FLAGS_V) $1
endef

define BUILD_I
	iverilog $(FLAGS_I) -s $2 -o $(BUILD_DIR_I)/$2 $1
endef
define BUILD_V
	verilator --binary -j 4 $(FLAGS_V) $(BUILD_FLAGS_V) -o $2 $1  
endef

define BUILD_VPI_I
	# Manually invoke vpi to not polute dependancy list
	@$(MAKE) -f Makefile $3
	# Same as normal build
	iverilog $(FLAGS_I) -s $2 -o $(BUILD_DIR_I)/$2 $1
endef
define BUILD_VPI_V
	# Manually invoke vpi to not polute dependancy list
	@$(MAKE) -f Makefile $3
	verilator --binary -j 4 $(FLAGS_V) --vpi --Mdir $(VPI_DIR)/$(BUILD_VPI_DIR_$(SIM)) $(BUILD_FLAGS_V) -o $2 $1  
endef

define RUN_I
	vvp $(BUILD_DIR_I)/$1
endef
define RUN_V
	./$(BUILD_DIR_V)/$1 $(if $(wave),+trace) 
endef
define RUN_VPI_I
	vvp -M $(VPI_DIR)/$(BUILD_VPI_DIR_$(SIM)) -mtb $(BUILD_DIR_$(SIM))/$1
endef
define RUN_VPI_V
	$(call RUN_V,$1)
endef
config:
	@mkdir -p ${CONF}

build:
	@mkdir -p $(BUILD_DIR_I)

# DEPS 

pcs_tx_deps := pcs_tx.v pcs_enc_lite.v _64b66b_tx.v gearbox_tx.v am_tx.v am_lane_tx.v  
pcs_rx_deps := pcs_rx.v block_sync_rx.v am_lock_rx.v lane_reorder_rx.v deskew_rx.v deskew_lane_rx.v _64b66b_rx.v dec_lite_rx.v 

# LINT

lint_64b66b_tx : _64b66b_tx.v build
	$(call LINT_$(SIM), _64b66b_tx.v, $64b66b_tx)

lint_64b66b_rx : _64b66b_rx.v build
	$(call LINT_$(SIM), _64b66b_rx.v,$,64b66b_rx)

lint_pcs_tx : $(pcs_tx_deps)
	$(call LINT_$(SIM), $(pcs_tx_deps),pcs_tx)

lint_pcs_rx: $(pcs_rx_deps)
	$(call LINT_$(SIM), $(pcs_rx_deps),pcs_rx)
	
# Test bench 

_64b66b_tb: _64b66b_tx.v _64b66b_rx.v ${TB_DIR}/_64b66b_tb.v
	$(call BUILD_$(SIM),$^,$@)

gearbox_tx_tb: gearbox_tx.v ${TB_DIR}/gearbox_tx_tb.sv
	$(call BUILD_$(SIM),$^,$@)

block_sync_rx_tb: block_sync_rx.v $(TB_DIR)/block_sync_rx_tb.sv 
	$(call BUILD_$(SIM),$^,$@)

am_lock_rx_tb: am_lock_rx.v $(TB_DIR)/am_lock_rx_tb.sv 
	$(call BUILD_$(SIM),$^,$@)

lane_reorder_rx_tb: lane_reorder_rx.v $(TB_DIR)/lane_reorder_rx_tb.sv 
	$(call BUILD_$(SIM),$^,$@)

xgmii_dec_rx_tb: dec_lite_rx.v xgmii_dec_intf_rx.v $(TB_DIR)/xgmii_dec_rx_tb.sv 
	$(call BUILD_$(SIM),$^,$@)

deskew_rx_tb: deskew_rx.v deskew_lane_rx.v $(TB_DIR)/deskew_rx_tb.sv 
	$(call BUILD_$(SIM),$^,$@)

# VPI Test bench 
am_tx_tb :  am_tx.v am_lane_tx.v ${TB_DIR}/am_tx_tb.sv 
	$(call BUILD_VPI_$(SIM),$^,$@,vpi_marker)

pcs_tb : ${TB_DIR}/pcs_tb.sv $(pcs_tx_deps) $(pcs_rx_deps) 
	$(call BUILD_VPI_$(SIM),$^,$@,vpi)

# Classic TB run 
run_64b66b: _64b66b_tb
	$(call RUN_$(SIM),$^)

run_gearbox_tx: gearbox_tx_tb
	$(call RUN_$(SIM),$^)

run_sync_rx: block_sync_rx_tb
	$(call RUN_$(SIM),$^)

run_am_lock_rx: am_lock_rx_tb
	$(call RUN_$(SIM),$^)

run_lane_reorder_rx: lane_reorder_rx_tb
	$(call RUN_$(SIM),$^)

run_xgmii_dec_rx: xgmii_dec_rx_tb
	$(call RUN_$(SIM),$^)

run_deskew_rx: deskew_rx_tb
	$(call RUN_$(SIM),$^)

# Run VPI
run_pcs_cmd := vvp -M $(VPI_DIR)/$(BUILD_VPI_DIR_$(SIM)) -mtb $(BUILD_DIR_$(SIM))/pcs_tb
run_pcs: pcs_tb
	$(call RUN_VPI_$(SIM),$^)
	#$(run_pcs_cmd)

run_am_tx: am_tx_tb
	mv $(VPI_DIR)/$(BUILD_VPI_DIR_$(SIM))/tb_marker.vpi $(VPI_DIR)/$(BUILD_VPI_DIR_$(SIM))/tb.vpi
	#vvp -M $(VPI_DIR)/$(BUILD_VPI_DIR_$(SIM)) -mtb $(BUILD_DIR_$(SIM))/am_tx_tb
	$(call RUN_VPI_$(SIM),$^)

run: run_pcs

vpi:
	cd $(VPI_DIR) && $(MAKE) $(BUILD_VPI_DIR_$(SIM))/tb.vpi SIM=$(SIM) $(DEFINES) $(40GBASE_ARGS)

vpi_marker:
	cd $(VPI_DIR) && $(MAKE) $(BUILD_VPI_DIR_$(SIM))/tb_marker.vpi SIM=$(SIM) $(DEFINES) $(40GBASE_ARGS)

wave: config
	${VIEW} $(WAVE_DIR)/${WAVE_FILE} ${CONF}/${WAVE_CONF}

valgrind: 
	valgrind $(run_pcs_cmd)

valgrind2: pcs_tb vpi
	valgrind --leak-check=full --show-leak-kinds=all --fullpath-after=. $(run_pcs_cmd)

profile: pcs_tb vpi
	valgrind --tool=callgrind $(run_pcs_cmd)

gdb: pcs_tb vpi
	gdb -x $(CONF)/$(GDB_CONF) --args vvp -M $(VPI_DIR)/$(BUILD_DIR_I) -mtb $(BUILD_DIR_I)/pcs_tb

clean:
	cd $(VPI_DIR) && $(MAKE) clean
	rm -f vgcore.* vgd.log*
	rm -f callgrind.out.*
	rm -fr $(BUILD_DIR_I)/*
	rm -fr $(BUILD_DIR_V)/*
	rm -fr $(WAVE_DIR)/*
	
