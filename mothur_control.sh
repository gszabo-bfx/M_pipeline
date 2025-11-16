#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p path-to-project"
   echo -e "\t-p path : path/to/project/folder"
   # echo -e "\t-b Description of what is parameterB"
   # echo -e "\t-c Description of what is parameterC"
   exit 1 # Exit script after printing help
}

while getopts "p:b:c:" opt
do
   case "$opt" in
      p ) path="$OPTARG" ;;
      # b ) parameterB="$OPTARG" ;;
      # c ) parameterC="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$path" ] # || [ -z "$parameterB" ] || [ -z "$parameterC" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
#echo "$parameterA"
#echo "$parameterB"
#echo "$parameterC"




# usage script path/to/project/folder 

mkdir ${path}/fq_in
mkdir ${path}/cut_out

# -path "./fq_in" -prune -o -> exclude "./fq_in" and continue others
find ${path} -path "./fq_in" -prune -o -name "*.fastq.gz" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fastq.gz" -print -exec rm {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq.gz" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq.gz" -print -exec rm {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fastq" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fastq" -print -exec rm {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq" -print -exec rm {} ${path}/fq_in \;

for i in ${path}/fq_in/*R1_001.fastq.gz
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
	-o ${path}/cut_out/$R1_base \
	-p ${path}/cut_out/$R2_base \
	${path}/fq_in/$R1_base \
	${path}/fq_in/$R2_base
done

gzip ${path}/fq_in/*.fastq
gzip ${path}/fq_in/*.fq
