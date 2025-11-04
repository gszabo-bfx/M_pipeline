#!/bin/bash

proj_name="MyMetaAmpProject"

proj_wd="/home/gyula/bfx_sources/tmp/MOTHUT_dev"
fq_in="$proj_wd/fq_mini"
oligos="$proj_wd/oligos.txt"
res_out="$proj_wd/res_out"
log_out="$proj_wd/log_out"

thr=2 # number of processors

mothur --quiet "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	make.file(
		inputdir=$fq_in, 
		prefix=$proj_name, 
		type=gz
		);"

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after make.file to continue.. " -n1 -s

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	make.contigs(
		inputdir=$fq_in,
		outputdir=$res_out, 
		file=$fq_in/$proj_name.files, 
		processors=$thr,
		deltaq=10
		);"
	# make.contigs output files
	# MyMetaAmpProject.contigs.count_table
	# MyMetaAmpProject.contigs_report 
	# MyMetaAmpProject.scrap.contigs.fasta 
	# MyMetaAmpProject.trim.contigs.fasta 

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after make.contigs to continue.. " -n1 -s

mothur "#set.logfile(
			name=$log_out/project_log.txt, 
			append=T
			);
		summary.seqs(
			fasta=$res_out/$proj_name.trim.contigs.fasta, 
			count=$res_out/$proj_name.contigs.count_table,
			processors=$thr
			);"
		# summary.seqs output files
		# MyMetaAmpProject.trim.contigs.summary

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after summary.seq to continue.. " -n1 -s

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	screen.seqs(
		fasta=$res_out/$proj_name.trim.contigs.fasta, 
		count=$res_out/$proj_name.contigs.count_table,
		processors=$thr,
	       	maxambig=8, 
		minlength=280, 
		maxlength=500, 
		maxhomop=7
		);"
	# screen.seqs output files
	# MyMetaAmpProject.contigs.good.count_table
	# MyMetaAmpProject.trim.contigs.bad.accnos
	# MyMetaAmpProject.trim.contigs.good.fasta

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after screen.seqs to continue.. " -n1 -s

	mothur "#set.logfile(
			name=$log_out/project_log.txt, 
			append=T
			);
		summary.seqs(
			fasta=$res_out/$proj_name.trim.contigs.good.fasta, 
			count=$res_out/$proj_name.contigs.good.count_table,
			processors=$thr
			);"
		# summary.seqs output files
		# MyMetaAmpProject.trim.contigs.good.summary

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after summary.seqs to continue.. " -n1 -s

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	unique.seqs(
		fasta=$res_out/$proj_name.trim.contigs.good.fasta, 
		count=$res_out/$proj_name.contigs.good.count_table
		);"
	# unique.seqs output files
	# MyMetaAmpProject.trim.contigs.good.unique.fasta
	# MyMetaAmpProject.trim.contigs.good.count_table

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after unique.seqs to continue.. " -n1 -s

	mothur "#set.logfile(
			name=$log_out/project_log.txt, 
			append=T
			);
		summary.seqs(
			fasta=$res_out/$proj_name.trim.contigs.good.unique.fasta, 
			count=$res_out/$proj_name.trim.contigs.good.count_table,
			processors=$thr
			);"
		# summary.seqs output
		# MyMetaAmpProject.trim.contigs.good.unique.summary

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after summary.seqs to continue.. " -n1 -s

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	screen.seqs(
		fasta=$res_out/$proj_name.trim.contigs.good.unique.fasta, 
		count=$res_out/$proj_name.trim.contigs.good.count_table, 
		maxambig=0
		);"
	# screen.seq outputs
	# MyMetaAmpProject.trim.contigs.good.good.count_table
	# MyMetaAmpProject.trim.contigs.good.unique.bad.accnos
	# MyMetaAmpProject.trim.contigs.good.unique.good.fasta

ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after screen.seqs 2 to continue.. " -n1 -s

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	count.groups(
		count=$res_out/$proj_name.trim.contigs.good.count_table
		);"


min_count=$(awk 'NR==1 { min=$2 } FNR==NR {if ($2 < min) min=$2}END{print min}' $res_out/$proj_name.trim.contigs.good.count.summary)
echo "min count: $min_count"
awk 'NR==1 { min=$2 } FNR==NR {if ($2 < min) min=$2}END{print min}' $res_out/$proj_name.trim.contigs.good.count.summary


ls -alt /home/gyula/bfx_sources/tmp/MOTHUT_dev/res_out
read -p "Press key after count.groups to continue.. " -n1 -s

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	sub.sample(
		fasta=$res_out/$proj_name.trim.contigs.good.unique.good.fasta, 
		count=$res_out/$proj_name.trim.contigs.good.good.count_table, 
		size=45000, 
		persample=T
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	count.groups(
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	align.seqs(
		fasta=current, 
		reference=silva.nr_v138_1.align
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	summary.seqs(
		fasta=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.align, 
		count=$res_out/$proj_name.trim.contigs.good.good.subsample.count_table
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	screen.seqs(
		fasta=current, 
		count=current, 
		start=11895, 
		end=25316
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	summary.seqs(
		fasta=current, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	filter.seqs(
		fasta=current, 
		trump=.
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	summary.seqs(
		fasta=current, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	unique.seqs(
		fasta=current, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	pre.cluster(
		fasta=current, 
		count=current, 
		diffs=4
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	summary.seqs(
		fasta=current, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	chimera.uchime(
		fasta=current, 
		count=current, 
		dereplicate=T
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	split.abund(
		cutoff=1, 
		fasta=current, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	classify.seqs(
		fasta=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.fasta, 
		count=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.count_table, 
		method=wang, 
		reference=silva.nr_v138_1.align, 
		taxonomy=silva.nr_v138_1.tax, 
		cutoff=80
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	summary.seqs(
		fasta=current, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	remove.lineage(
		fasta=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.fasta, 
		count=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.count_table, 
		taxonomy=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.nr_v138_1.wang.taxonomy, 
		taxon=Archaea-Chloroplast-Mitochondria-Eukaryota-unknown
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	summary.tax(
		taxonomy=current, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	dist.seqs(
		fasta=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.pick.fasta, 
		cutoff=0.15
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	cluster(
		column=current, 
		count=current, 
		cutoff=0.15, 
		method=average
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	make.shared(
		list=current, 
		label=0.03, 
		count=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	count.groups(
		shared=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	classify.otu(
		list=current, 
		taxonomy=current, 
		label=0.03, 
		count=current, 
		basis=sequence, 
		relabund=T
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	get.oturep(
		list=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.pick.an.list, 
		fasta=gyor2411.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.pick.fasta, 
		count=$res_out/$proj_name.trim.contigs.good.unique.good.subsample.good.filter.unique.precluster.denovo.uchime.abund.pick.count_table, 
		method=abundance, 
		cutoff=0.03
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	degap.seqs(
		fasta=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	summary.single(
		shared=current, 
		subsample=T, 
		calc=nseqs-coverage-sobs-chao-ace-shannon-invsimpson
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	sub.sample(
		shared=current
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	rarefaction.single(
		shared=current, 
		calc=sobs, 
		freq=100
		);"



exit

	make.contigs(
		inputdir=$fq_in, 
		outputdir=$res_out, 
		file=$fq_in/$proj_name.files, 
		trimoverlap=T, 
		oligos=$oligos, 
		pdiffs=2, 
		checkorient=t, 
		processors=2
	);

	
mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	get.current(
		);"

mothur "#set.logfile(
		name=$log_out/project_log.txt, 
		append=T
		);
	count.groups(
		count=current
		);"
