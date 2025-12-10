#!/bin/bash

# usage script path/to/project/folder 

mkdir ${1}fq_in
mkdir ${1}cut_out

# -path "./fq_in" -prune -o -> exclude "./fq_in" and continue others
find $1 -path "./fq_in" -prune -o -name "*.fastq.gz" -print -exec cp {} ${1}fq_in \;
find $1 -path "./fq_in" -prune -o -name "*.fastq.gz" -print -exec rm {} ${1}fq_in \;
find $1 -path "./fq_in" -prune -o -name "*.fq.gz" -print -exec cp {} ${1}fq_in \;
find $1 -path "./fq_in" -prune -o -name "*.fq.gz" -print -exec rm {} ${1}fq_in \;
find $1 -path "./fq_in" -prune -o -name "*.fastq" -print -exec cp {} ${1}fq_in \;
find $1 -path "./fq_in" -prune -o -name "*.fastq" -print -exec rm {} ${1}fq_in \;
find $1 -path "./fq_in" -prune -o -name "*.fq" -print -exec cp {} ${1}fq_in \;
find $1 -path "./fq_in" -prune -o -name "*.fq" -print -exec rm {} ${1}fq_in \;

for i in ${1}fq_in/*R1_001.fastq.gz
do
	R1_base=$(basename "$i")
	R2_base="$(sed "s/R1/R2/g" <<< $R1_base)"

cutadapt \
	-g CCTACGGGNGGCWGCAG -a GGATTAGATACCCBDGTAGTC \
	-G GACTACHVGGGTATCTAATCC -A CTGCWGCCNCCCGTAGG \
	--cores=8 \
	--discard-untrimmed \
	--max-n 0 \
	--minimum-length 0 \
	-o ${1}cut_out/$R1_base \
	-p ${1}cut_out/$R2_base \
	${1}fq_in/$R1_base \
	${1}fq_in/$R2_base
done

gzip ${1}fq_in/*.fastq
gzip ${1}fq_in/*.fq
