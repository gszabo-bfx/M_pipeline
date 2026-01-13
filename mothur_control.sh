#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p path -t threads -a assay -n R1_name_pattern -f fqtype -e error -d RefDB"
   echo -e "\t-p path : path/to/project/folder"
   echo -e "\t-t threads : number of threads"
   echo -e "\t-a assay : amplicon target assay can be used: [ILMNV3V4] [PATE]"
   echo -e "\t-n R1_name_pattern : pattern to recognise R1 read eg [_R1_001.fastq.gz] or [_1.fq.gz]"
   echo -e "\t-f fqtype: in put fastq file type [fastq] or [gz]"
   echo -e "\t-e error: set from 0-0.9999 (proportional) or 1-n (number of errors) | default: 0.1"
   echo -e "\t-d RefDB: nr OR seed"
   exit 1 # Exit script after printing help
}

while getopts "p:t:a:n:f:e:d:" opt
do
   case "$opt" in
      p ) path="$OPTARG" ;;
      t ) threads="$OPTARG" ;;
      a ) assay="$OPTARG" ;;
      n ) R1tag="$OPTARG" ;;
      f ) fqtype="$OPTARG" ;;
      e ) error="$OPTARG" ;;
      d ) refdb="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$path" ] || [ -z "$threads" ] || [ -z "$assay" ] || [ -z "$R1tag" ] || [ -z "$fqtype" ] || [ -z "$error" ] || [ -z "$refdb" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# set base pathes
# ctrl_wd=$PWD
# res_wd=${path%/}

########################
# check for conda and packages
# # check if conda env available
# if conda env list | grep ".*MOTHUR.*" >/dev/null 2>&1; then echo "true" ; else echo "false" ; fi
# check if command executable
# if command -v cutadapt &>/dev/null && command -v git &>/dev/null ; then echo "true" ; else echo "false" ; fi

#################
# activate MOTHUR environment
eval "$(conda shell.bash hook)"
conda activate MOTHUR
echo "$CONDA_PREFIX conda environment activated"

################
# Begin script in case all parameters are correct
#echo "path $path"
#echo "assay $assay"
#echo "R1tag $R1tag"

# exit

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

# move all fq file into fq_in
find ${path} -path "${path}/fq_in" -prune -o -name "*${R1tag}" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "${path}/fq_in" -prune -o -name "*${R1tag/1/2}" -print -exec cp {} ${path}/fq_in \;
find ${path} -path "${path}/fq_in" -prune -o -name "*${R1tag}" -print -exec rm {} \;
find ${path} -path "${path}/fq_in" -prune -o -name "*${R1tag/1/2}" -print -exec rm {} \;

gzip ${path}/fq_in/*.fastq
gzip ${path}/fq_in/*.fq

# exit

###########
# create a temp copy of batch script file to set parameters
cp ./mothur_one.batch ./mothur_one.batch.local

#################
# insert inline parameters into mothur batch file
#
# Environment variable substitution in sed
# https://stackoverflow.com/questions/584894/environment-variable-substitution-in-sed
# set path
sed  -i 's@proj_wd=.*@proj_wd='"$path"'@g' ./mothur_one.batch.local 
# set threads
sed  -i 's@proc=.*@proc='"$threads"'@g' ./mothur_one.batch.local 
# set fqtype
sed  -i 's@fqtype=.*@fqtype='"$fqtype"'@g' ./mothur_one.batch.local 
# set RefDB path
if [ $refdb == "seed" ]
then
	sed  -i 's@alignref=.*@alignref='"$ctrl_wd"'/RefDB/silva.seed_v138_2.align@g' ./mothur_one.batch.local 
	sed  -i 's@taxonref=.*@taxonref='"$ctrl_wd"'/RefDB/silva.seed_v138_2.tax@g' ./mothur_one.batch.local 
else
	sed  -i 's@alignref=.*@alignref='"$ctrl_wd"'/RefDB/silva.nr_v138_2.align@g' ./mothur_one.batch.local 
	sed  -i 's@taxonref=.*@taxonref='"$ctrl_wd"'/RefDB/silva.nr_v138_2.tax@g' ./mothur_one.batch.local 
fi

#exit 

#################
# select assay related parameters
# source https://linuxize.com/post/bash-case-statement/
case $assay in

  ILMNV3V4)
    R1_FW="CCTACGGGNGGCWGCAG"
    R1_RV="GGATTAGATACCCBDGTAGTC"
    R2_FW="GACTACHVGGGTATCTAATCC"
    R2_RV="CTGCWGCCNCCCGTAGG"
    sed -i 's@pcr_seq_start=.*@pcr_seq_start=6428@g' ./mothur_one.batch.local
    sed -i 's@pcr_seq_end=.*@pcr_seq_end=23440@g' ./mothur_one.batch.local
    ;;

  PATE)
    R1_FW="GTGYCAGMAGBNKCGGTVA"
    R1_RV="ATTAGADACCYBNKTAGTCY"
    R2_FW="RGACTAMNVRGGTHTCTAAT"
    R2_RV="TBACCGMNVCTKCTGRCAC"
    sed -i 's@pcr_seq_start=.*@pcr_seq_start=13862@g' ./mothur_one.batch.local
    sed -i 's@pcr_seq_end=.*@pcr_seq_end=23444@g' ./mothur_one.batch.local
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

> ${path}/log_out/cutadapt_stdout.txt

for i in ${path}/fq_in/*${R1tag}
do
	sample_name=$(basename -s $R1tag $i)
	R1_name="${sample_name}${R1tag}"
	R2_name="${sample_name}${R1tag/1/2}"

cutadapt \
	-g $R1_FW -a $R1_RV \
	-G $R2_FW -A $R2_RV \
	--cores=$threads \
	--discard-untrimmed \
	--max-n 0 \
	--minimum-length 0 \
	-e $error \
	-o ${path}/cut_out/$R1_name \
	-p ${path}/cut_out/$R2_name \
	${path}/fq_in/$R1_name \
	${path}/fq_in/$R2_name \
	 | tee -a ${path}/log_out/cutadapt_stdout.txt
done

# exit

eval "$(conda shell.bash hook)"
conda activate MOTHUR
echo "$CONDA_PREFIX conda environment activated"

mothur ./mothur_one.batch.local
#rm ./mothur_one.batch.local

# copy few results file at the end
cp $path/res_out/*.an.0.03.cons.tax.summary $path/res_out/${path##*/}_taxonomy_table.summary
cp $path/res_out/*.an.0.03.cons.taxonomy $path/res_out/${path##*/}_taxonomy_list.taxonomy
cp $path/res_out/*.an.groups.ave-std.summary $path/res_out/${path##*/}_ASV_diversity_data.summary
cp $path/res_out/*.an.0.03.subsample.shared $path/res_out/${path##*/}_ASV_distribution.shared
cp $path/res_out/*unique.precluster.denovo.uchime.abund.pick.an.shared $path/res_out/${path##*/}_ASV00_abundance.tsv
cp $path/res_out/*unique.precluster.denovo.uchime.abund.pick.an.0.03.subsample.shared $path/res_out/${path##*/}_ASV00_abundance_subsampled.tsv
cp $path/res_out/*good.filter.unique.precluster.denovo.uchime.abund.pick.an.unique.rep.ng.fasta $path/res_out/${path##*/}_ASV00_sequences.fasta

# crate crona chart
python3 ./mothur_krona_XML_gy.py $path/res_out/${path##*/}_taxonomy_table.summary > $path/res_out/${path##*/}_taxonomy_table.summary.xml
ktImportXML -o $path/res_out/${path##*/}_taxonomy_table.summary.html $path/res_out/${path##*/}_taxonomy_table.summary.xml

