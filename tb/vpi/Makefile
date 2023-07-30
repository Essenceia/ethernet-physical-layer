
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


BUILD=build
INC=inc
IVERILOG=/home/pitchu/AUR/iverilog
FLAGS = -std=gnu99 -Wall -Wextra -Wconversion -Wshadow -Wundef -fno-common -Wno-unused-parameter -Wno-type-limits -fpic
DEFINES = $(if $(debug),-DDEBUG -g) $(if $(40GBASE), -D_40GBASE)
CC = cc -g $(DEFINES)
LD = cc -g $(DEFINES)  


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
	$(CC) -o $@ -I$(INC) -I$(IVERILOG) -c tv.c $(FLAGS)

$(BUILD)/tb_utils.o: tb_utils.c tb_utils.h
	@mkdir -p $(@D)
	$(CC) -o $@ -I$(INC) -I$(IVERILOG) -c tb_utils.c $(FLAGS)

$(BUILD)/tb.o: tb.c tb.h
	@mkdir -p $(@D)
	$(CC) -o $@ -I$(INC) -I$(IVERILOG) -c tb.c $(FLAGS)

40g_deps := $(if $(40GBASE),pcs_marker.o)
test_deps_ := test.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o tb_fifo.o tv.o $(40g_deps)
test_deps := $(foreach x,$(test_deps_),$(BUILD)/$x)

tb_deps_ := tb.o tv.o tb_utils.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o tb_fifo.o $(40g_deps)
tb_deps := $(foreach x,$(tb_deps_),$(BUILD)/$x)
$(info TB DEPS $(tb_deps))

test: $(test_deps)
	$(LD) -o test -g $^

$(BUILD)/tb.vpi: $(tb_deps)
	@mkdir -p $(@D)
	$(LD) -shared -o $(BUILD)/tb.vpi $^ -lvpi

clean:
	rm -rf $(BUILD)/*	
	rm -f test	
	rm -f vgcore.*	

TB_DIR=tb

