ifndef debug
#debug :=
endif

TB_DIR=tb
BUILD=build
CONF=conf
FLAGS=-Wall -g2012 -gassertions -gstrict-expr-width
WAVE_FILE=wave.vcd
VIEW=gtkwave
WAVE_CONF=wave.conf

all: wave

build:
	@mkdir -p ${BUILD}

64b66b_tx : 64b66b.v build
	iverilog ${FLAGS} -s scrambler_64b66b_tx -o ${BUILD}/64b66b_tx 64b66b.v

64b66b_tb: 64b66b_tx ${TB_DIR}/64b66b_tb.v
	iverilog ${FLAGS} -s lite_64b66b_tb -o ${BUILD}/lite_64b66b_tb 64b66b.v ${TB_DIR}/64b66b_tb.v

gearbox_tx_tb: gearbox_tx.v build
	iverilog ${FLAGS} -s gearbox_tx_tb -o ${BUILD}/gearbox_tx_tb gearbox_tx.v ${TB_DIR}/gearbox_tx_tb.sv

pcs_10g_enc_tb: pcs_10g_enc.v pcs_10g_enc_lite.v
	iverilog ${FLAGS} -s pcs_10g_enc_tb -o ${BUILD}/pcs_10g_enc_tb pcs_10g_enc.v pcs_10g_enc_lite.v ${TB_DIR}/pcs_10g_enc_tb.sv

pcs_10g_tx : pcs_10g_tx.v pcs_10g_enc_lite.v 64b66b.v gearbox_tx.v 
	iverilog ${FLAGS} -s pcs_10g_tx -o ${BUILD}/pcs_10g_tx pcs_10g_tx.v pcs_10g_enc_lite.v 64b66b.v gearbox_tx.v

run_64b66b: 64b66b_tb
	vvp ${BUILD}/lite_64b66b_tb

run_gearbox_tx: gearbox_tx_tb
	vvp ${BUILD}/gearbox_tx_tb

run_pcs_10g_enc: pcs_10g_enc_tb
	vvp ${BUILD}/pcs_10g_enc_tb

wave:
	${VIEW} ${BUILD}/${WAVE_FILE} ${CONF}/${WAVE_CONF}

clean:
	rm -fr ${BUILD}/*
	
