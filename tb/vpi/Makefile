BUILD=build
INC=inc
IVERILOG=/home/pitchu/AUR/iverilog
FLAGS = -std=gnu99 -Wall -Wextra -Wconversion -Wshadow -Wundef -fno-common -Wno-unused-parameter -Wno-type-limits -fpic
DEFINES = $(if $(debug),-DDEBUG -g) $(if $(40GBASE), -D_40GBASE)
CC = cc ${DEFINES} 
LD = cc

test: test.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o
	$(LD) -o test -g test.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o

test.o:test.c
	$(CC) -c test.c $(FLAGS)

pcs_gearbox.o: pcs_gearbox.h pcs_gearbox.c pcs_defs.h
	$(CC) -c pcs_gearbox.c $(FLAGS)

pcs_enc.o: pcs_enc.c pcs_enc.h pcs_defs.h
	$(CC) -c pcs_enc.c $(FLAGS)

64b66b.o : 64b66b.c 64b66b.h
	$(CC) -c 64b66b.c $(FLAGS)

pcs_tx.o: pcs_tx.h pcs_tx.c pcs_defs.h 
	$(CC) -c pcs_tx.c $(FLAGS)

moldudp64.o: moldudp64.c moldudp64.h
	$(CC) -c moldudp64.c $(FLAGS)

axis.o: axis.c axis.h
	$(CC) -c axis.c $(FLAGS)
 
clean:
	rm -f test	
	rm -f *.o
	rm -f vgcore.*	

TB_DIR=tb
