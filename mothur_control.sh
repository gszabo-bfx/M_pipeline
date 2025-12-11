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
      n ) R1tag="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$path" ] || [ -z "$assay" ] || [ -z "$R1tag" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi



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

# exit

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
for i in ${path}/fq_in/*${R1tag}
do
	sample_name=$(basename -s $R1tag $i)
	R1_name="${sample_name}${R1tag}"
	R2_name="${sample_name}${R1tag/1/2}"

cutadapt \
	-g $R1_FW -a $R1_RV \
	-G $R2_FW -A $R2_RV \
	--cores=8 \
	--discard-untrimmed \
	--max-n 0 \
	--minimum-length 0 \
	-o ${path}/cut_out/$R1_name \
	-p ${path}/cut_out/$R2_name \
	${path}/fq_in/$R1_name \
	${path}/fq_in/$R2_name \
	 | tee ${path}/log_out/cutadapt_stdout.txt
done

gzip ${path}/fq_in/*.fastq
gzip ${path}/fq_in/*.fq


###########
# create a temp copy of batch script file to set parameters
cp ./mothur_one.batch ./mothur_one.batch.local


#################
# insert inline parameters into mothur batch file
#
# Environment variable substitution in sed
# https://stackoverflow.com/questions/584894/environment-variable-substitution-in-sed
sed  -i 's@proj_wd=.*@proj_wd='"$path"'@g' ./mothur_one.batch.local 

#exit 

###########
# call mothur batch script
#

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
cp $path/res_out/*unique.precluster.denovo.uchime.abund.an.shared $path/res_out/${path##*/}_ASV00_abundance.tsv
cp $path/res_out/*unique.precluster.denovo.uchime.abund.an.0.03.subsample.shared $path/res_out/${path##*/}_ASV00_abundance_subsampled.tsv
cp $path/res_out/*good.filter.unique.precluster.denovo.uchime.abund.an.unique.rep.ng.fasta $path/res_out/${path##*/}_ASV00_sequences.fasta

# crate crona chart
python3 ./mothur_krona_XML_gy.py $path/res_out/${path##*/}_taxonomy_table.summary > $path/res_out/${path##*/}_taxonomy_table.summary.xml
ktImportXML -o $path/res_out/${path##*/}_taxonomy_table.summary.html $path/res_out/${path##*/}_taxonomy_table.summary.xml

