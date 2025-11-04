
#ktImportXML <(python -u mothur_krona_XML_gy.py ~/bfx_sources/tmp/MOTHUT_dev/pipeline_MiSeq_SOP/res_out/final.opti_mcc.0.03.cons.tax.summary)
ktImportXML -o $1.html <(python -u mothur_krona_XML_gy.py $1)
