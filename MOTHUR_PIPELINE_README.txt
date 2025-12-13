
The scripts in this package is intenned to use for Amplicon Metagenome Analysis with MOTHUR workflow
In this workflow one can analyse amplicon metagenomic data from raw Illumina PE reads up to taxa abundance and richness tables

Packages used in this scripts:
cutadapt and mothur must be in the path or in MOTHUR conda environment

Script files in this package:
mothur_control.sh : BASH script to collect inline variables, run cutadapt, trigger mothur_one.batch script
mothur_one.batch : main MOTHUR pipeline batch script with MOTHUR workflow commands
mothur_krona_XML_gy.py : python script to convert tax.summary.table to xml format can be used to generate krona diagram

## Recent MOTHUR workflow control files can be found in 
https://github.com/gszabo-bfx/M_pipeline.git

## USAGE

- Prepare your folder and input files
	- create a project folder
	- copy or move raw Illumna PE sequencing fastq.gz files into your project folder

- Run mothur_control.sh scrtipt without any inline parameter to get the help txt

- Check mothur_on-batch file for more parameters, set parameters if necessary. (pls create backup befor modification)

- Run mothur_control.sh scrtipt with the required parameters
