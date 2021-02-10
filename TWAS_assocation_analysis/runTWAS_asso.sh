### pipeline contributed by Zhishan Chen

perl -F"\t" -lane 'print "$F[0]\t$F[1]\t$F[10]\t$F[6]\t$F[11]\t$F[11]"' CRC_Asian_model_chr*_model_summaries.txt |sed 's/\t/,/g' |grep -v "NA" > CRC_Asian_models.csv
awk -F"," '!seen[$1,$2]++' CRC_Asian_models.csv  > temp
mv temp CRC_Asian_models.csv 
sed -i '1d' CRC_Asian_models.csv
sed -i '1i gene,genename,pred.perf.R2,n.snps.in.model,pred.perf.pval,pred.perf.qval'  CRC_Asian_models.csv

# get a file with weigth of models
cat CRC_Asian_model_chr*_weights.txt >  CRC_Asian_weights.txt
awk '!seen[$1,$2]++' CRC_Asian_weights.txt > temp
mv temp CRC_Asian_weights.txt
sed -i '1d' CRC_Asian_weights.txt 
cat CRC_Asian_weights.txt| perl -F"\t" -lane '{print "$F[1],$F[0],$F[5],$F[3],$F[4]"}' > CRC_Asian_weights.csv 
sed -i '1i rsid,gene,weight,ref_allele,eff_allele' CRC_Asian_weights.csv

# make a database
Rscript weight2db.R

# get a file with covariate
cat CRC_Asian_model_chr*_covariances.txt > CRC_Asian_cov.txt
sed 's/ /\t/g' CRC_Asian_cov.txt > CRC_Asian_cov.txt_2
awk '!seen[$1,$2,$3]++' CRC_Asian_cov.txt_2 > CRC_Asian_cov.txt_3
mv CRC_Asian_cov.txt_3 CRC_Asian_cov.txt
gzip CRC_Asian_cov.txt
rm CRC_Asian_cov.txt_2 

# PrediXcan
conda activate imlabtools
/scratch/sbcs/chenzs/software/MetaXcan-master/software/SPrediXcan.py --model_db_path CRC_Asian.db --covariance CRC_Asian_cov.txt.gz --gwas_folder /scratch/sbcs/chenzs/CRC_TWAS/MetaXcan --gwas_file_pattern ".*gz" --snp_column SNP --effect_allele_column A1 --non_effect_allele_column A2 --beta_column BETA  --pvalue_column P --output_file  CRC_Asian.TWAS