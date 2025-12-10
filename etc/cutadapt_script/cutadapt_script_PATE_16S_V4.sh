#!/bin/bash

# usage script path/to/project/folder 


for i in $1/fq_in/*R1_001.fastq.gz
do
	R1_base=$(basename "$i")
	R2_base="$(sed "s/R1/R2/g" <<< $R1_base)"

cutadapt \
	-g GTGYCAGMAGBNKCGGTVA -a ATTAGADACCYBNKTAGTCY \
	-G RGACTAMNVRGGTHTCTAAT -A TBACCGMNVCTKCTGRCAC \
	--cores=60 \
	--discard-untrimmed \
	--max-n 0 \
	--minimum-length 0 \
	-o $1/cut_out/$R1_base \
	-p $1/cut_out/$R2_base \
	$1/fq_in/$R1_base \
	$1/fq_in/$R2_base
done

