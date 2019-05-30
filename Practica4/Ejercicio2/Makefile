LIBS =
LIB_DIR =
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: pescalar_serie pescalar_par1 pescalar_par2 clear

#omp1: omp1.c
#	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

#omp2: omp2.c
#	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_serie: pescalar_serie.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par1: pescalar_par1.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par2: pescalar_par2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

#multiplicar_serie: multiplicar_serie.c arqo4.c
#	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

#multiplicar_par1: multiplicar_par1.c arqo4.c
#	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

#multiplicar_par2: multiplicar_par2.c arqo4.c
#	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

#multiplicar_par3: multiplicar_par3.c arqo4.c
#	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)



clean:
	rm -f *.o *~ pescalar_serie pescalar_par1 pescalar_par2

clear:
	rm -f *.o *~
