#!/bin/bash

# inicializar variables
P=8
Ninicio=$((2000 + 1024*P))
Npaso=64
Nfinal=$((Ninicio + 1024))
reps=1
cachemin=10
cachemax=13

make

# borrar el fichero DAT y el fichero PNG
rm -f  *.png *.dat
# generar los ficheros DAT vacío
touch slow1.dat fast1.dat slow2.dat fast2.dat



for ((i=cachemin; i<=cachemax; i++)); do


	size=$((2**i))

	# Generamos el fichero cache_size
	touch cache_"$size".dat

	echo "Cache size: $size"

	for ((n=Ninicio; n <= Nfinal; n+=Npaso*2)); do

		slow1_D1mw=0
		slow1_D1mr=0
		slow2_D1mw=0
		slow2_D1mr=0
		fast1_D1mw=0
		fast1_D1mr=0
		fast2_D1mw=0
		fast2_D1mr=0

		echo "$n/$Nfinal"

		for ((I=0; I<reps; I++)); do

			#Hacemos valgrind cachegrind para slow y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="slow1.dat" --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 ./slow $n >&/dev/null
			slow1_D1mw=$(awk '{print $1+$2}' <<< "$slow1_D1mw $(cg_annotate slow1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}'| sed -u 's/,//g')")
			slow1_D1mr=$(awk '{print $1+$2}' <<< "$slow1_D1mr $(cg_annotate slow1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}'| sed -u 's/,//g')")

			#Hacemos valgrind cachegrind para fast y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="fast1.dat" --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 ./fast $n >&/dev/null
			fast1_D1mw=$(awk '{print $1+$2}' <<< "$fast1_D1mw $(cg_annotate fast1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}'| sed -u 's/,//g')")
			fast1_D1mr=$(awk '{print $1+$2}' <<< "$fast1_D1mr $(cg_annotate fast1.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}'| sed -u 's/,//g')")

			#Hacemos valgrind cachegrind para slow (N+64) y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="slow2.dat" --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 ./slow $((n+64)) >&/dev/null
			slow2_D1mw=$(awk '{print $1+$2}' <<< "$slow2_D1mw $(cg_annotate slow2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}'| sed -u 's/,//g')")
			slow2_D1mr=$(awk '{print $1+$2}' <<< "$slow2_D1mr $(cg_annotate slow2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}'| sed -u 's/,//g')")

			#Hacemos valgrind cachegrind para fast (N+64) y guardamos el numero de fallos de escritura y el numero de fallos de escritura

			valgrind --tool=cachegrind --cachegrind-out-file="fast2.dat" --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 ./fast $((n+64)) >&/dev/null
			fast2_D1mw=$(awk '{print $1+$2}' <<< "$fast2_D1mw $(cg_annotate fast2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $8}'| sed -u 's/,//g')")
			fast2_D1mr=$(awk '{print $1+$2}' <<< "$fast2_D1mr $(cg_annotate fast2.dat | head -n 30 | grep 'PROGRAM TOTALS' | awk '{print $5}'| sed -u 's/,//g')")

		done

		slow_D1mw=$(awk '{print $1/$2}' <<<"$slow1_D1mw $reps")
		slow_D1mr=$(awk '{print $1/$2}' <<<"$slow1_D1mr $reps")
		fast_D1mw=$(awk '{print $1/$2}' <<<"$fast1_D1mw $reps")
		fast_D1mr=$(awk '{print $1/$2}' <<<"$fast1_D1mr $reps")
		echo "$n	$slow_D1mr $slow_D1mw	$fast_D1mr $fast_D1mw" >> cache_"$size".dat

		slow_D1mw=$(awk '{print $1/$2}' <<<"$slow2_D1mw $reps")
		slow_D1mr=$(awk '{print $1/$2}' <<<"$slow2_D1mr $reps")
		fast_D1mw=$(awk '{print $1/$2}' <<<"$fast2_D1mw $reps")
		fast_D1mr=$(awk '{print $1/$2}' <<<"$fast2_D1mr $reps")
		echo "$((n+64))	$slow_D1mr $slow_D1mw	$fast_D1mr $fast_D1mw" >> cache_"$size".dat


	done

done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Escritura"
set xlabel "Tamanio matriz"
set ylabel "D1 MW"
set key right bottom
set grid
set term png
set output "cache_escritura.png"
plot "cache_1024.dat" using 1:3 with lines lw 3 title "slow1024", \
     "cache_1024.dat" using 1:5 with lines lw 3 title "fast1024", \
		 "cache_2048.dat" using 1:3 with lines lw 3 title "slow2048", \
		 "cache_2048.dat" using 1:5 with lines lw 3 title "fast2048", \
		 "cache_4096.dat" using 1:3 with lines lw 3 title "slow4096", \
		 "cache_4096.dat" using 1:5 with lines lw 3 title "fast4096", \
		 "cache_8192.dat" using 1:3 with lines lw 3 title "slow8192", \
		 "cache_8192.dat" using 1:5 with lines lw 3 title "fast8192"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Slow-Fast Lectura"
set xlabel "Tamanio matriz"
set ylabel "D1 MR"
set key right bottom
set grid
set term png
set output "cache_lectura.png"
plot "cache_1024.dat" using 1:2 with lines lw 3 title "slow1024", \
     "cache_1024.dat" using 1:4 with lines lw 3 title "fast1024", \
		 "cache_2048.dat" using 1:2 with lines lw 3 title "slow2048", \
		 "cache_2048.dat" using 1:4 with lines lw 3 title "fast2048", \
		 "cache_4096.dat" using 1:2 with lines lw 3 title "slow4096", \
		 "cache_4096.dat" using 1:4 with lines lw 3 title "fast4096", \
		 "cache_8192.dat" using 1:2 with lines lw 3 title "slow8192", \
		 "cache_8192.dat" using 1:4 with lines lw 3 title "fast8192"
replot
quit
END_GNUPLOT

make clean
