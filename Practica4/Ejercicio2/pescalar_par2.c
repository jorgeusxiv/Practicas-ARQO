// ----------- Arqo P4-----------------------
// pescalar_par2
//
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "arqo4.h"

int main(int argc, char const *argv[])
{
	float *A=NULL, *B=NULL;
	long long k=0;
	struct timeval fin,ini;
	float sum=0;
	int arg,tamanio;

	if(argc != 3){
		perror("El formato de entrada es el siguiente: -nº de threads -tamanio matriz\n");
	}
	arg = atoi( argv[1] );
	omp_set_num_threads(arg);

	tamanio = atoi(argv[2]);

	A = generateVector(tamanio);
	B = generateVector(tamanio);
	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}

	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;
	#pragma omp parallel for reduction(+:sum)
	for(k=0;k<tamanio;k++)
	{
		sum = sum + A[k]*B[k];
		//printf("%f\n",sum);
	}

	/* Fin del computo */
	gettimeofday(&fin,NULL);

	printf("Resultado: %f\n",sum);
	printf("Tiempo: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
