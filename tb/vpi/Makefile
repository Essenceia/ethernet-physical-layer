BUILD=build
INC=inc
IVERILOG=/home/pitchu/AUR/iverilog
FLAGS = -std=gnu99 -Wall -Wextra -Wconversion -Wshadow -Wundef -fno-common -Wno-unused-parameter -Wno-type-limits -fpic
DEFINES = $(if $(debug),-DDEBUG -g) $(if $(40GBASE), -D_40GBASE)
CC = cc ${DEFINES} 
LD = cc $(if $(debug),-DDEBUG -g)  

test: test.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o tb_fifo.o tv.o
	$(LD) -o test -g test.o pcs_gearbox.o pcs_enc.o 64b66b.o pcs_tx.o tb_fifo.o tv.o 

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

tb_fifo.o: tb_fifo.h tb_fifo.c
	$(CC) -c tb_fifo.c $(FLAGS)

tv.o: tv.h tv.c
	$(CC) -c tv.c $(FLAGS)
 
clean:
	rm -f test	
	rm -f *.o
	rm -f vgcore.*	

TB_DIR=tb
