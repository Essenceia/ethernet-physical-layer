ifndef debug
#debug :=
endif

TB_DIR=tb
VPI_DIR=$(TB_DIR)/vpi
BUILD=build
CONF=conf
FLAGS=-Wall -g2012 -gassertions -gstrict-expr-width
WAVE_FILE=wave.vcd
VIEW=gtkwave
WAVE_CONF=wave.conf
DEBUG_FLAG=$(if $(debug), debug=1)

all: wave

build:
	@mkdir -p ${BUILD}

64b66b_tx : 64b66b.v build
	iverilog ${FLAGS} -s scrambler_64b66b_tx -o ${BUILD}/64b66b_tx 64b66b.v

64b66b_tb: 64b66b_tx ${TB_DIR}/64b66b_tb.v
	iverilog ${FLAGS} -s lite_64b66b_tb -o ${BUILD}/lite_64b66b_tb 64b66b.v ${TB_DIR}/64b66b_tb.v

gearbox_tx_tb: gearbox_tx.v build
	iverilog ${FLAGS} -s gearbox_tx_tb -o ${BUILD}/gearbox_tx_tb gearbox_tx.v ${TB_DIR}/gearbox_tx_tb.sv

pcs_10g_enc_tb: pcs_10g_enc.v pcs_enc_lite.v
	iverilog ${FLAGS} -s pcs_10g_enc_tb -o ${BUILD}/pcs_10g_enc_tb pcs_10g_enc.v pcs_enc_lite.v ${TB_DIR}/pcs_10g_enc_tb.sv

pcs_10g_tx : pcs_10g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v 
	iverilog ${FLAGS} -s pcs_10g_tx -o ${BUILD}/pcs_10g_tx pcs_10g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v

pcs_40g_tx : pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v alignement_marker_tx.v alignement_marker_lane_tx.v 
	iverilog ${FLAGS} -s pcs_40g_tx -o ${BUILD}/pcs_40g_tx pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v alignement_marker_tx.v alignement_marker_lane_tx.v

pcs_40g_tx_tb : ${TB_DIR}/pcs_40g_tx_tb.sv pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v alignement_marker_tx.v alignement_marker_lane_tx.v 
	iverilog ${FLAGS} -s pcs_40g_tx_tb -o ${BUILD}/pcs_40g_tx_tb pcs_40g_tx.v pcs_enc_lite.v 64b66b.v gearbox_tx.v alignement_marker_tx.v alignement_marker_lane_tx.v ${TB_DIR}/pcs_40g_tx_tb.sv


run_64b66b: 64b66b_tb
	vvp ${BUILD}/lite_64b66b_tb

run_gearbox_tx: gearbox_tx_tb
	vvp ${BUILD}/gearbox_tx_tb

run_pcs_40g_tx: pcs_40g_tx_tb vpi
	vvp -M $(VPI_DIR) -mtb ${BUILD}/pcs_40g_tx_tb

vpi:
	cd $(VPI_DIR) && $(MAKE) tb.vpi $(DEBUG_FLAG) 40GBASE=1 

wave:
	${VIEW} ${BUILD}/${WAVE_FILE} ${CONF}/${WAVE_CONF}

valgrind: test vpi
	valgrind vvp -M $(VPI_DIR) -mtb $(BUILD)/hft_tb

gdb: test vpi
	gdb --args vvp -M $(VPI_DIR) -mtb $(BUILD)/hft_tb
  
clean:
	cd $(VPI_DIR) && $(MAKE) clean
	rm -fr ${BUILD}/*
	
