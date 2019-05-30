#!/bin/bash

# inicializar variables
P=8
Ninicio=$((10000 + 1024*P))
Npaso=64
Nfinal=$((Ninicio + 1024))
Reps=14
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png

make all

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."
# bucle para N desde P hasta Q
#for N in $(seq $Ninicio $Npaso $Nfinal);


	for ((N = Ninicio; N < Nfinal-64 ; N += 2*Npaso)); do
		echo "N: $N / $Nfinal..."

			slowTime1=0
			slowTime2=0
			fastTime1=0
			fastTime2=0
			# ejecutar los programas slow y fast consecutivamente con tamaño de matriz N
			# para cada uno, filtrar la línea que contiene el tiempo y seleccionar la
			# tercera columna (el valor del tiempo). Dejar los valores en variables
			# para poder imprimirlos en la misma línea del fichero de datos
			for ((I = 0 ; I <= Reps ; I += 1)); do
			slowTime1=$(awk '{print $1+$2}' <<< "$slowTime1 $(./slow $N | grep 'time' | awk '{print $3}')")
			slowTime2=$(awk '{print $1+$2}' <<< "$slowTime2 $(./slow $((N+64)) | grep 'time' | awk '{print $3}')")
			fastTime1=$(awk '{print $1+$2}' <<< "$fastTime1 $(./fast $N | grep 'time' | awk '{print $3}')")
			fastTime2=$(awk '{print $1+$2}' <<< "$fastTime2 $(./fast $((N+64)) | grep 'time' | awk '{print $3}')")
			done

			slowTime=$(awk '{print $1/$2}' <<< "$slowTime1 $Reps")
			fastTime=$(awk '{print $1/$2}' <<< "$fastTime1 $Reps")
			echo "$N	$slowTime	$fastTime" >> $fDAT
			slowTime=$(awk '{print $1/$2}' <<< "$slowTime2 $Reps")
			fastTime=$(awk '{print $1/$2}' <<< "$fastTime2 $Reps")
			echo "$((N+64))	$slowTime	$fastTime" >> $fDAT

done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT

make clean
