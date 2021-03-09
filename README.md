# Colorectal-TWAS-in-East-Asians
==
* [Introduction](#Introduction)
* [Data resource](#Data resource)
* [Pipeline](#Pipeline)

<a name="Introduction"/>

# Introduction
In a recent analysis, we have identified 25 genes for which, their genetically predicted expressions were associated with CRC risk in European populations. This work ihas been published at Gastroenterology in 2020 (PMID: 33058866)

In a follow-up work, we reported inaugural results from a large CRC TWAS among 23,572 CRC cases and 48,700 controls of East Asian ancestry from the Asia Colorectal Cancer Consortium (ACCC). We genotyped DNA samples from 364 East Asian CRC patients and conducted RNA-sequencing on their tumor-adjacent normal colon tissues to build statistical models of genetically predicted gene expression. We applied these predictive models and GWAS summary statistics from East Asian patients (23,572 cases and 48,700 controls) to investigate associations of predicted gene expression with CRC risk. We have submitted this work for publication.Specific Aim: To search for colorectal cancer (CRC) susceptibility genes, we performed a transcriptome-wide association study (TWAS) in East-Asians. 

<a name="Data resource"/>

# Data resource

1. GWAS sumamry statistics data from ACCC including 23,572 cases and 48,700 controls of East Asians

2. We genotyped DNA samples from 364 CRC East-Asian patients and conducted RNA-sequencing in their tumor-adjacent normal colon tissues to build genetic models to predict gene expression. 

3. Published TWAS findings among 125,478 Subjects in European populations (PMID: 33058866)

##@ Overall pipeline below 
This repository contains analysis code of the Asian CRC_TWAS project.


<a name="Pipeline"/>

# Pipeline 
---
contributed by Zhishan Chen, 2021
--- 
### step1: gene expression data processing (
### This pipeline of RNA-seq analysis is modified based on the pipeline of GTEx Consortium.
References from GTEx

https://github.com/broadinstitute/gtex-pipeline/blob/master/rnaseq/README.md https://github.com/broadinstitute/gtex-pipeline/tree/master/qtl

reference genome

ftp://ftp.broadinstitute.org/pub/seq/references/Homo_sapiens_assembly19.fasta



### Reference annotation: the GENCODE v19 annotation gtf

#The GENCODE annotation should be patched to use Ensembl chromosome names:
```
zcat gencode.v19.annotation.gtf.gz | sed 's/chrM/chrMT/;s/chr//' > gencode.v19.annotation.patched_contigs.gtf   
python3 collapse_annotation.py gencode.v19.annotation.patched_contigs.gtf gencode.v19.annotation.patched_contigs.genes.gtf
building the indexes


bash index.sh
```
####  alignment of sequencing reads and quantification of gene expression
```
bash run_STAR.sh
```
aggregating outputs

####  Sample-level outputs in GCT format can be concatenated using combine_GCTs.py(from GTEx)
```
python3 combine_GCTs.py samples_gct.list tpm.gct
python3 combine_GCTs.py samples_gct.list_counts count.gct
```
#### expression normalization
```
python3.7 eqtl_prepare_expression.py tpm.gct count.gct gencode.v19.annotation.patched_contigs.genes.gtf sample.list chromsome_ID.list  prefix.output --tpm_threshold 0.1 --count_threshold 6 --sample_frac_threshold 0.2 --normalization_method tmm
convert sample ID
```
#### Sample ID in expression file were matched to it in genotype data. Meanwhile, the covariate files (five gentoype PCs, gender and genotyping platform) were generated.
```
 Rscript run_Convert_ID.R
```
####  Calculate PEER factors
```
 gunzip gene.expression.bed.gz
 sed -i 's/#chr/chr/g' gene.expression.bed
 Rscript run_PEER_adjusted.R
```
 ### step2: building gene expression prediction model
```
 Rscript model_building.R chromsome_ID
```
 ### step3: SPrediXcan analysis
```
 bash TWAS_association.sh
```
