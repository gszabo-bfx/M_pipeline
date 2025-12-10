#!/bin/bash

# usage script path/to/project/folder 

mkdir ${1}fq_in
mkdir ${1}cut_out

find $1 -name "*.fastq.gz" -exec cp {} ${1}fq_in \;
find $1 -name "*.fq.gz" -exec cp {} ${1}fq_in \;
find $1 -name "*.fastq" -exec cp {} ${1}fq_in \;
find $1 -name "*.fq" -exec cp {} ${1}fq_in \;

gzip ${1}/fq_in/*.fastq
gzip ${1}/fq_in/*.fq

for i in ${1}fq_in/*R1_001.fastq.gz
do
	R1_base=$(basename "$i")
	R2_base="$(sed "s/R1/R2/g" <<< $R1_base)"

cutadapt \
	-g CCTACGGGNGGCWGCAG -a GGATTAGATACCCBDGTAGTC \
	-G GACTACHVGGGTATCTAATCC -A CTGCWGCCNCCCGTAGG \
	--cores=60 \
	--discard-untrimmed \
	--max-n 0 \
	--minimum-length 0 \
	-o ${1}cut_out/$R1_base \
	-p ${1}cut_out/$R2_base \
	${1}fq_in/$R1_base \
	${1}fq_in/$R2_base
done

gunzip ${1}cut_out/*
