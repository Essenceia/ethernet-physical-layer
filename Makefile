ifndef debug
#debug :=
endif

TB_DIR=tb
BUILD=build
VPI_DIR=$(TB_DIR)/vpi
CONF=conf
FLAGS=-Wall -g2012 -gassertions -gstrict-expr-width
WAVE_FILE=wave.vcd
VIEW=gtkwave
WAVE_CONF=wave.conf
GDB_CONF=.gdbinit
DEBUG_FLAG=$(if $(debug), debug=1)
DEFINES=$(DEBUG_FLAG) $(if $(40GBASE), 40GBASE=1)
all: run wave
40GBASE_ARGS:= 40GBASE=1
config:
	@mkdir -p ${CONF}

build:
	@mkdir -p ${BUILD}

64b66b_tx : 64b66b.v build
	iverilog ${FLAGS} -s scrambler_64b66b_tx -o ${BUILD}/64b66b_tx 64b66b.v

64b66b_rx : 66b64b.v build
	iverilog ${FLAGS} -s descrambler_64b66b_rx -o ${BUILD}/64b66b_rx 66b64b.v

64b66b_tb: 64b66b_tx 64b66b_rx ${TB_DIR}/64b66b_tb.v
	iverilog ${FLAGS} -s lite_64b66b_tb -o ${BUILD}/lite_64b66b_tb 64b66b.v 66b64b.v ${TB_DIR}/64b66b_tb.v

gearbox_tx_tb: gearbox_tx.v build
	iverilog ${FLAGS} -s gearbox_tx_tb -o ${BUILD}/gearbox_tx_tb gearbox_tx.v ${TB_DIR}/gearbox_tx_tb.sv

pcs_10g_enc_tb: pcs_10g_enc.v pcs_enc_lite.v
	iverilog ${FLAGS} -s pcs_10g_enc_tb -o ${BUILD}/pcs_10g_enc_tb pcs_10g_enc.v pcs_enc_lite.v ${TB_DIR}/pcs_10g_enc_tb.sv

pcs_10g_tx : pcs_10g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v 
	iverilog ${FLAGS} -s pcs_10g_tx -o ${BUILD}/pcs_10g_tx pcs_10g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v

pcs_40g_tx : pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v am_tx.v am_lane_tx.v 
	iverilog ${FLAGS} -s pcs_40g_tx -o ${BUILD}/pcs_40g_tx pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v am_tx.v am_lane_tx.v

pcs_40g_tx_tb : ${TB_DIR}/pcs_40g_tx_tb.sv pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v am_tx.v am_lane_tx.v 
	iverilog ${FLAGS} -s pcs_40g_tx_tb -o ${BUILD}/pcs_40g_tx_tb pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v am_tx.v am_lane_tx.v ${TB_DIR}/pcs_40g_tx_tb.sv

am_tx_tb : ${TB_DIR}/am_tx_tb.sv am_tx.v am_lane_tx.v 
	iverilog ${FLAGS} -s am_tx_tb -o ${BUILD}/am_tx_tb am_tx.v am_lane_tx.v ${TB_DIR}/am_tx_tb.sv

block_sync_rx_tb: $(TB_DIR)/block_sync_rx_tb.sv block_sync_rx.v
	iverilog ${FLAGS} -s block_sync_rx_tb -o ${BUILD}/block_sync_rx_tb block_sync_rx.v ${TB_DIR}/block_sync_rx_tb.sv

am_lock_rx_tb: $(TB_DIR)/am_lock_rx_tb.sv am_lock_rx.v
	iverilog ${FLAGS} -s am_lock_rx_tb -o ${BUILD}/am_lock_rx_tb am_lock_rx.v ${TB_DIR}/am_lock_rx_tb.sv

lane_reorder_rx_tb: $(TB_DIR)/lane_reorder_rx_tb.sv lane_reorder_rx.v
	iverilog ${FLAGS} -s lane_reorder_rx_tb -o ${BUILD}/lane_reorder_rx_tb lane_reorder_rx.v ${TB_DIR}/lane_reorder_rx_tb.sv

xgmii_dec_rx_tb: $(TB_DIR)/xgmii_dec_rx_tb.sv dec_lite_rx.v xgmii_dec_intf_rx.v
	iverilog ${FLAGS} -s xgmii_dec_rx_tb -o ${BUILD}/xgmii_dec_rx_tb dec_lite_rx.v xgmii_dec_intf_rx.v ${TB_DIR}/xgmii_dec_rx_tb.sv

deskew_rx_tb: $(TB_DIR)/deskew_rx_tb.sv deskew_rx.v deskew_lane_rx.v
	iverilog ${FLAGS} -s deskew_rx_tb -o ${BUILD}/deskew_rx_tb deskew_lane_rx.v deskew_rx.v ${TB_DIR}/deskew_rx_tb.sv


run_64b66b: 64b66b_tb
	vvp ${BUILD}/lite_64b66b_tb

run_gearbox_tx: gearbox_tx_tb
	vvp ${BUILD}/gearbox_tx_tb

run_pcs_40g_tx: pcs_40g_tx_tb vpi
	vvp -M $(VPI_DIR)/$(BUILD) -mtb ${BUILD}/pcs_40g_tx_tb

run_am_tx: am_tx_tb vpi_marker
	mv $(VPI_DIR)/$(BUILD)/tb_marker.vpi $(VPI_DIR)/$(BUILD)/tb.vpi
	vvp -M $(VPI_DIR)/$(BUILD) -mtb ${BUILD}/am_tx_tb

run_sync_rx: block_sync_rx_tb
	vvp ${BUILD}/block_sync_rx_tb

run_am_lock_rx: am_lock_rx_tb
	vvp ${BUILD}/am_lock_rx_tb

run_lane_reorder_rx: lane_reorder_rx_tb
	vvp ${BUILD}/lane_reorder_rx_tb

run_xgmii_dec_rx: xgmii_dec_rx_tb
	vvp ${BUILD}/xgmii_dec_rx_tb

run_deskew_rx: deskew_rx_tb
	vvp ${BUILD}/deskew_rx_tb

run: run_pcs_40g_tx

vpi:
	cd $(VPI_DIR) && $(MAKE) $(BUILD)/tb.vpi $(DEFINES) $(40GBASE_ARGS)

vpi_marker:
	cd $(VPI_DIR) && $(MAKE) $(BUILD)/tb_marker.vpi $(DEFINES) $(40GBASE_ARGS)

wave: config
	${VIEW} ${BUILD}/${WAVE_FILE} ${CONF}/${WAVE_CONF}

valgrind: 
	valgrind vvp -M $(VPI_DIR)/$(BUILD) -mtb $(BUILD)/pcs_40g_tx_tb

valgrind2: pcs_40g_tx_tb vpi
	valgrind --leak-check=full --show-leak-kinds=all --fullpath-after=. vvp -M $(VPI_DIR)/$(BUILD) -mtb $(BUILD)/pcs_40g_tx_tb

gdb: pcs_40g_tx_tb vpi
	gdb -x $(CONF)/$(GDB_CONF) --args vvp -M $(VPI_DIR)/$(BUILD) -mtb $(BUILD)/pcs_40g_tx_tb

clean:
	cd $(VPI_DIR) && $(MAKE) clean
	rm -fr ${BUILD}/*
	rm vgcore.* vgd.log*
	
