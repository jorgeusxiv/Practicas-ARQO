#!/bin/bash

# inicializar variables
P=8
Ninicio=$((64 + 64*P))
Npaso=16
Nfinal=$((Ninicio + 64))
reps=5

# borrar el fichero DAT y el fichero PNG
rm -f  *.png *.dat
# generar los ficheros DAT vacío
touch normal1.dat trasp1.dat normal2.dat trasp2.dat mult.dat

# compilamos

make all



	# Generamos el fichero cache_size


	for ((n=Ninicio; n <= Nfinal; n+=Npaso*2)); do

		echo "$n/$Nfinal"

		normal1=0
		normal1_D1mw=0
		normal1_D1mr=0
		normal2=0
		normal2_D1mw=0
		normal2_D1mr=0
		trasp1=0
		trasp1_D1mw=0
		trasp1_D1mr=0
		trasp2=0
		trasp2_D1mw=0
		trasp2_D1mr=0

		for ((I=0; I<reps; I++)); do

			#Hacemos valgrind cachegrind para normal y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="normal1.dat" -q ./normal $n > aux.dat


			normal1=$(awk '{print $1+$2}' <<< "$normal1 $(grep 'time' aux.dat | awk '{print $3}')")
			normal1_D1mw=$(awk '{print $1+$2}' <<< "$normal1_D1mw $(cg_annotate normal1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}' | sed -u 's/,//g')")
			normal1_D1mr=$(awk '{print $1+$2}' <<< "$normal1_D1mr $(cg_annotate normal1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}' | sed -u 's/,//g')")

			#Hacemos valgrind cachegrind para trasp y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="trasp1.dat" -q ./trasp $n >aux.dat

			trasp1=$(awk '{print $1+$2}' <<< "$trasp1 $(grep 'time' aux.dat | awk '{print $3}')")
		 	trasp1_D1mw=$(awk '{print $1+$2}' <<< "$trasp1_D1mw $(cg_annotate trasp1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}' | sed -u 's/,//g')")
		 	trasp1_D1mr=$(awk '{print $1+$2}' <<< "$trasp1_D1mr $(cg_annotate trasp1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}' | sed -u 's/,//g')")

			#Hacemos valgrind cachegrind para normal (N+16) y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="normal2.dat" -q ./normal $((n+16)) >aux.dat

			normal2=$(awk '{print $1+$2}' <<< "$normal2 $(grep 'time' aux.dat | awk '{print $3}')")
			normal2_D1mw=$(awk '{print $1+$2}' <<< "$normal2_D1mw $(cg_annotate normal2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}' | sed -u 's/,//g')")
			normal2_D1mr=$(awk '{print $1+$2}' <<< "$normal2_D1mr $(cg_annotate normal2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}' | sed -u 's/,//g')")

			#Hacemos valgrind cachegrind para trasp (N+16) y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="trasp2.dat" -q ./trasp $((n+16)) >aux.dat

			trasp2=$(awk '{print $1+$2}' <<< "$trasp2 $(grep 'time' aux.dat | awk '{print $3}')")
		 	trasp2_D1mw=$(awk '{print $1+$2}' <<< "$trasp2_D1mw $(cg_annotate trasp2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}' | sed -u 's/,//g')")
		 	trasp2_D1mr=$(awk '{print $1+$2}' <<< "$trasp2_D1mr $(cg_annotate trasp2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}' | sed -u 's/,//g')")

		done

		normal=$(awk '{print $1/$2}' <<<"$normal1 $reps")
		normal_D1mw=$(awk '{print $1/$2}' <<<"$normal1_D1mw $reps")
		normal_D1mr=$(awk '{print $1/$2}' <<<"$normal1_D1mr $reps")
		trasp=$(awk '{print $1/$2}' <<<"$trasp1 $reps")
	 	trasp_D1mw=$(awk '{print $1/$2}' <<<"$trasp1_D1mw $reps")
	 	trasp_D1mr=$(awk '{print $1/$2}' <<<"$trasp1_D1mr $reps")
		echo "$n	$normal $normal_D1mr $normal_D1mw	 $trasp $trasp_D1mr  $trasp_D1mw" >> mult.dat

		normal=$(awk '{print $1/$2}' <<<"$normal2 $reps")
		normal_D1mw=$(awk '{print $1/$2}' <<<"$normal2_D1mw $reps")
		normal_D1mr=$(awk '{print $1/$2}' <<<"$normal2_D1mr $reps")
		trasp=$(awk '{print $1/$2}' <<<"$trasp2 $reps")
	 	trasp_D1mw=$(awk '{print $1/$2}' <<<"$trasp2_D1mw $reps")
	 	trasp_D1mr=$(awk '{print $1/$2}' <<<"$trasp2_D1mr $reps")
		echo "$((n+16))	$normal $normal_D1mr $normal_D1mw	 $trasp $trasp_D1mr  $trasp_D1mw" >> mult.dat


	done



echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Tiempos de ejecucion"
set xlabel "Tamanio matriz"
set ylabel "Tiempo de ejecucion"
set key right bottom
set grid
set term png
set output "mult_time.png"
plot "mult.dat" using 1:2 with lines lw 3 title "normal", \
     "mult.dat" using 1:5 with lines lw 3 title "trasp"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Fallos cache"
set xlabel "Tamanio matriz"
set ylabel "Nº Fallos"
set key right bottom
set grid
set term png
set output "mult_cache.png"
plot "mult.dat" using 1:3 with lines lw 3 title "Normal mr", \
     "mult.dat" using 1:4 with lines lw 3 title "Normal mw", \
		 "mult.dat" using 1:6 with lines lw 3 title "Trasp mr", \
		 "mult.dat" using 1:7 with lines lw 3 title "Trasp mw"
replot
quit
END_GNUPLOT

make clean
