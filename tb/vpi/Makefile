
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

# Define simulator we are going to use, priority to iverilog
ifndef SIM
SIM:=I
endif

INC=inc

AUR=$(HOME)/AUR
VPI_INC_I=$(AUR)/iverilog
VPI_INC_V=$(AUR)/verilator/include


FLAGS = -std=gnu99 -Wall -Wextra -Wconversion -Wshadow -Wundef -fno-common -Wno-unused-parameter -Wno-type-limits -fpic

DEFINES = $(if $(debug),-DDEBUG -g) 
DEFINES +=$(if $(40GBASE), -D_40GBASE)

ifeq ($(SIM),I)
BUILD=build
COMPILER=cc
else
BUILD=obj_vpi
COMPILER=g++
FLAGS += -fpermissive
DEFINES += -DVERILATOR
endif

$(info Using SIM=$(SIM), building to $(BUILD) dir)


CC = $(COMPILER) -g $(DEFINES)
LD = $(COMPILER) -g $(DEFINES)  


$(BUILD)/test.o:test.c
	@mkdir -p $(@D)
	$(CC) -o $@ -c test.c $(FLAGS)

$(BUILD)/pcs_gearbox.o: pcs_gearbox.h pcs_gearbox.c pcs_defs.h
	@mkdir -p $(@D)
	$(CC) -o $@ -c pcs_gearbox.c $(FLAGS)

$(BUILD)/pcs_enc.o: pcs_enc.c pcs_enc.h pcs_defs.h
	@mkdir -p $(@D)
	$(CC) -o $@ -c pcs_enc.c $(FLAGS)

$(BUILD)/64b66b.o : 64b66b.c 64b66b.h
	@mkdir -p $(@D)
	$(CC) -o $@ -c 64b66b.c $(FLAGS)

$(BUILD)/pcs_marker.o : pcs_marker.c pcs_marker.h pcs_defs.h
	@mkdir -p $(@D)
	$(CC) -o $@ -c pcs_marker.c $(FLAGS)


$(BUILD)/pcs_tx.o: pcs_tx.h pcs_tx.c pcs_defs.h 
	@mkdir -p $(@D)
	$(CC) -o $@ -c pcs_tx.c $(FLAGS)

$(BUILD)/tb_fifo.o: tb_fifo.h tb_fifo.c
	@mkdir -p $(@D)
	$(CC) -o $@ -c tb_fifo.c $(FLAGS)

$(BUILD)/tv.o: tv.c tv.h
	@mkdir -p $(@D)
	$(CC) -o $@ -I$(INC) -I$(VPI_INC_$(SIM)) -c tv.c $(FLAGS)

$(BUILD)/tb_utils.o: tb_utils.c tb_utils.h
	@mkdir -p $(@D)
	$(CC) -o $@ -I$(INC) -I$(VPI_INC_$(SIM)) -c tb_utils.c $(FLAGS)

$(BUILD)/tb.o: tb.c tb.h
	@mkdir -p $(@D)
	$(CC) -o $@ -I$(INC) -I$(VPI_INC_$(SIM)) -c tb.c $(FLAGS)

$(BUILD)/tb_marker.o: tb_marker.c tb_marker.h
	@mkdir -p $(@D)
	$(CC) -o $@ -I$(INC) -I$(VPI_INC_$(SIM)) -c tb_marker.c $(FLAGS)


40g_deps := $(if $(40GBASE),pcs_marker.o)
test_deps_ := test.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o tb_fifo.o tv.o $(40g_deps)
test_deps := $(foreach x,$(test_deps_),$(BUILD)/$x)

tb_deps_ := tb.o tv.o tb_utils.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o tb_fifo.o $(40g_deps)
tb_deps := $(foreach x,$(tb_deps_),$(BUILD)/$x)
$(info TB DEPS $(tb_deps))

tb_marker_deps_ := tb_marker.o tb_utils.o pcs_marker.o
tb_marker_deps := $(foreach x,$(tb_marker_deps_),$(BUILD)/$x)

test: $(test_deps)
	$(LD) -o test -g $^

$(BUILD)/tb.vpi: $(tb_deps)
	@mkdir -p $(@D)
	$(LD) -shared -o $(BUILD)/tb.vpi $^ -lvpi

$(BUILD)/tb_marker.vpi: $(tb_marker_deps)
	@mkdir -p $(@D)
	$(LD) -shared -o $(BUILD)/tb_marker.vpi $^ -lvpi


clean:
	rm -rf build/*	
	rm -rf obj_vpi/*	
	rm -f test	
	rm -f vgcore.*	

TB_DIR=tb

