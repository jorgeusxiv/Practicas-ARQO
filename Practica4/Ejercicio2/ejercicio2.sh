#!/bin/bash

# inicializar variables

Ninicio=$((40000000))
Nfinal=$((900000000))
Npaso=$(((Nfinal - Ninicio)/10))
Reps=5



# borrar el fichero DAT y el fichero PNG
rm -f *.dat *.png

# generar los ficheros DAT vacíos
touch serie.dat thread_1.dat thread_2.dat thread_3.dat thread_4.dat


# bucle para N desde P hasta Q
#for N in $(seq $Ninicio $Npaso $Nfinal);

make all


	for ((N = Ninicio; N < Nfinal ; N += Npaso)); do
		echo "N: $N / $Nfinal..."

			timeSerie=0
			timeThread1=0
			timeThread2=0
			timeThread3=0
			timeThread4=0
			accelerationT1=0
			accelerationT2=0
			accelerationT3=0
			accelerationT4=0

			#COMMENTS

			for ((I = 0 ; I < Reps ; I += 1)); do
			timeSerie=$(awk '{print $1+$2}' <<< "$timeSerie $(./pescalar_serie $N | grep 'Tiempo' | awk '{print $2}')")
			timeThread1=$(awk '{print $1+$2}' <<< "$timeThread1 $(./pescalar_par2 1 $N | grep 'Tiempo' | awk '{print $2}')")
			timeThread2=$(awk '{print $1+$2}' <<< "$timeThread2 $(./pescalar_par2 2 $N | grep 'Tiempo' | awk '{print $2}')")
			timeThread3=$(awk '{print $1+$2}' <<< "$timeThread3 $(./pescalar_par2 3 $N | grep 'Tiempo' | awk '{print $2}')")
			timeThread4=$(awk '{print $1+$2}' <<< "$timeThread4 $(./pescalar_par2 4 $N | grep 'Tiempo' | awk '{print $2}')")

			done

			timeSerie=$(awk '{print $1/$2}' <<< "$timeSerie $Reps")
			timeThread1=$(awk '{print $1/$2}' <<< "$timeThread1 $Reps")
			timeThread2=$(awk '{print $1/$2}' <<< "$timeThread2 $Reps")
			timeThread3=$(awk '{print $1/$2}' <<< "$timeThread3 $Reps")
			timeThread4=$(awk '{print $1/$2}' <<< "$timeThread4 $Reps")

			accelerationT1=$(awk '{print $1/$2}' <<< "$timeSerie $timeThread1")
			accelerationT2=$(awk '{print $1/$2}' <<< "$timeSerie $timeThread2")
			accelerationT3=$(awk '{print $1/$2}' <<< "$timeSerie $timeThread3")
			accelerationT4=$(awk '{print $1/$2}' <<< "$timeSerie $timeThread4")


			echo "$N	$timeSerie" >> serie.dat
			echo "$N	$timeThread1 $accelerationT1" >> thread_1.dat
			echo "$N	$timeThread2 $accelerationT2" >> thread_2.dat
			echo "$N	$timeThread3 $accelerationT3" >> thread_3.dat
			echo "$N	$timeThread4 $accelerationT4" >> thread_4.dat


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
set output "comparison.png"
plot "serie.dat" using 1:2 with lines lw 2 title "Serie", \
     "thread_1.dat" using 1:2 with lines lw 2 title "Thread 1", \
		 "thread_2.dat" using 1:2 with lines lw 2 title "Thread 2", \
		 "thread_3.dat" using 1:2 with lines lw 2 title "Thread 3", \
		 "thread_4.dat" using 1:2 with lines lw 2 title "Thread 4"

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
set output "acceleration.png"
plot "thread_1.dat" using 1:3 with lines lw 2 title "Thread 1", \
		 "thread_2.dat" using 1:3 with lines lw 2 title "Thread 2", \
		 "thread_3.dat" using 1:3 with lines lw 2 title "Thread 3", \
		 "thread_4.dat" using 1:3 with lines lw 2 title "Thread 4"

replot
quit
END_GNUPLOT

make clean
