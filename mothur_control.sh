#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p path -a assay -n R1_name_pattern"
   echo -e "\t-p path : path/to/project/folder"
   echo -e "\t-a assay : amplicon target assay eg [ILMNV3V4] or [PATE]"
   echo -e "\t-n R1_name_pattern : pattern to recognise R1 read eg [_R1_001.fastq.gz] or [_1.fq.gz]"
   exit 1 # Exit script after printing help
}

while getopts "p:a:n:" opt
do
   case "$opt" in
      p ) path="$OPTARG" ;;
      a ) assay="$OPTARG" ;;
      n ) parameterC="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$path" ] || [ -z "$assay" ] #|| [ -z "$parameterC" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi



################
# Begin script in case all parameters are correct
#echo "$parameterA"
#echo "$parameterB"
#echo "$parameterC"


#################
# prep project folder
if [ ! -d ${path}/fq_in ]
then
	mkdir ${path}/fq_in
fi

if [ ! -d ${path}/cut_out ]
then
	mkdir ${path}/cut_out
fi

if [ ! -d ${path}/log_out ]
then
	mkdir ${path}/log_out
fi


# -path "./fq_in" -prune -o -> exclude "./fq_in" and continue others
find ${path} -path "./fq_in" -prune -o -name "*.fastq.gz" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fastq.gz" -print -exec rm {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq.gz" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq.gz" -print -exec rm {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fastq" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fastq" -print -exec rm {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "./fq_in" -prune -o -name "*.fq" -print -exec rm {} ${path}/fq_in \;

#################
# select assay
# source https://linuxize.com/post/bash-case-statement/
case $assay in

  ILMNV3V4)
    R1_FW="CCTACGGGNGGCWGCAG"
    R1_RV="GGATTAGATACCCBDGTAGTC"
    R2_FW="GACTACHVGGGTATCTAATCC"
    R2_RV="CTGCWGCCNCCCGTAGG"
    ;;

  PATE)
    R1_FW="GTGYCAGMAGBNKCGGTVA"
    R1_RV="ATTAGADACCYBNKTAGTCY"
    R2_FW="RGACTAMNVRGGTHTCTAAT"
    R2_RV="TBACCGMNVCTKCTGRCAC"
    ;;

  #PATTERN_N)
  #  STATEMENTS
  #  ;;

  *)
	  echo -e "\n\nAssay name is not valid"
    helpFunction
    ;;
esac

#################
# cutadapt
for i in ${path}/fq_in/*_R1_001.fastq.gz
do
	R1_base=$(basename "$i")
	R2_base="$(sed "s/R1/R2/g" <<< $R1_base)"

cutadapt \
	-g $R1_FW -a $R1_RV \
	-G $R2_FW -A $R2_RV \
	--cores=8 \
	--discard-untrimmed \
	--max-n 0 \
	--minimum-length 0 \
	-o ${path}/cut_out/$R1_base \
	-p ${path}/cut_out/$R2_base \
	${path}/fq_in/$R1_base \
	${path}/fq_in/$R2_base \
	 | tee ${path}/log_out/cutadapt_stdout.txt
done

gzip ${path}/fq_in/*.fastq
gzip ${path}/fq_in/*.fq
