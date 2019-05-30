#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


#include "arqo4.h"

float **compute(float **matrixA, float **matrixB, int n);

int main( int argc, char *argv[]){
	int n;
	float **m=NULL;
	float **p=NULL;
	struct timeval fin,ini;
	float **res=NULL;

	printf("Word size: %ld bits\n",8*sizeof(float));

	if( argc!=2 )
	{
		perror("El formato es: -tamanioMatriz");
	}
	n=atoi(argv[1]);
	m=generateMatrix(n);
	p=generateMatrix(n);

	if( !m )
	{
		return -1;
	}
	if( !p )
	{
		return -1;
	}


	gettimeofday(&ini,NULL);

	/* Main computation */
	res = compute(m,p,n);
	/* End of computation */

	gettimeofday(&fin,NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);


	freeMatrix(m);
	freeMatrix(p);
	freeMatrix(res);

	return 0;
}


float **compute(float **matrixA, float **matrixB, int n)
{
	float **res;
	int i,j,k;
	int c;

	res = generateEmptyMatrix(n);

	if( !res )
	{
		return NULL;
	}


	for(i=0;i<n;i++){
		for(j=0;j<n;j++){
			c = 0;
			for(k=0;k<n;k++){
				c += matrixA[i][k] * matrixB[k][j];
			}
			res[i][j] = c;
		}
	}
	return res;
}
