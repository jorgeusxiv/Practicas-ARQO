#!/bin/bash

# inicializar variables
P=8
Ninicio=$((512+$P))
Nfinal=$((1024+512+$P))
Npaso=64
Reps=5



# borrar el fichero DAT y el fichero PNG
rm -f *.dat *.png

# generar los ficheros DAT vacíos
touch multiplicacion_serie.dat multiplicacion_par3_hilo4.dat


make all


	for ((N = Ninicio; N < Nfinal ; N += Npaso)); do
		echo "N: $N / $Nfinal..."

			timeSerie=0
			timeThread4=0
			accelerationT4=0

			#COMMENTS

			for ((I = 0 ; I < Reps ; I += 1)); do
			timeSerie=$(awk '{print $1+$2}' <<< "$timeSerie $(./multiplicar_serie $N | grep 'time' | awk '{print $3}')")
			timeThread4=$(awk '{print $1+$2}' <<< "$timeThread4 $(./multiplicar_par3 $N 4 | grep 'time' | awk '{print $3}')")

			done

			timeSerie=$(awk '{print $1/$2}' <<< "$timeSerie $Reps")
			timeThread4=$(awk '{print $1/$2}' <<< "$timeThread4 $Reps")
			accelerationT4=$(awk '{print $1/$2}' <<< "$timeSerie $timeThread4")


			echo "$N	$timeSerie" >> multiplicacion_serie.dat
			echo "$N	$timeThread4 $accelerationT4" >> multiplicacion_par3_hilo4.dat


done



echo "Generating plot...\n"
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Execution Time"
set ylabel "Execution time (s)"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "comparison3.png"
plot "multiplicacion_serie.dat" using 1:2 with lines lw 2 title "Serie", \
		 "multiplicacion_par3_hilo4.dat" using 1:2 with lines lw 2 title "Thread 4"

replot
quit
END_GNUPLOT


echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Acceleration"
set ylabel "Acceleration (size/s^2)"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "acceleration3.png"
plot "multiplicacion_par3_hilo4.dat" using 1:3 with lines lw 2 title "Thread 4"

replot
quit
END_GNUPLOT

make clean
