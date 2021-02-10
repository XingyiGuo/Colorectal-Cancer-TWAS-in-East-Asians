module purge
module load GCC/6.4.0-2.28
module load STAR/2.5.4b
module load SAMtools/1.6

data=/path/to/your/data/folder

thread=8
sample_id=$1
fq_folder=${data}/${sample_id}
index_folder=/path/to/your/index/folder
mkdir /path/to/star-out/${sample_id}
output=/path/to/star-out/${sample_id}
prefix="${sample_id}."

## alignment
STAR --runMode alignReads \
     --runThreadN ${thread} \
     --genomeDir ${index_folder} \
     --twopassMode Basic \
     --outFilterMultimapNmax 20 \
     --alignSJoverhangMin 8 \
     --alignSJDBoverhangMin 1 \
     --outFilterMismatchNmax 999 \
     --outFilterMismatchNoverLmax 0.04 \
     --alignIntronMin 20 \
     --alignIntronMax 1000000 \
     --alignMatesGapMax 1000000 \
     --outFilterType BySJout \
     --outFilterScoreMinOverLread 0.33 \
     --outFilterMatchNminOverLread 0.33 \
     --limitSjdbInsertNsj 1200000 \
     --readFilesIn ${fq_folder}/${sample_id}_1.fq.gz ${fq_folder}/${sample_id}_2.fq.gz \
     --readFilesCommand zcat \
     --outFileNamePrefix ${output}/${prefix} \
     --outSAMstrandField intronMotif \
     --outFilterIntronMotifs None \
     --alignSoftClipAtReferenceEnds Yes \
     --quantMode TranscriptomeSAM GeneCounts \
     --outSAMtype BAM Unsorted \
     --outSAMunmapped Within \
     --genomeLoad NoSharedMemory \
     --outSAMattributes NH HI AS nM NM ch \
     --outSAMattrRGline ID:rg1 SM:sm1

## sort
samtools sort --threads ${thread} ${output}/${prefix}Aligned.out.bam  -o ${output}/${prefix}Aligned.sortedByCoord.out.bam
samtools index ${output}/${prefix}Aligned.sortedByCoord.out.bam
cp ${output}/STARpass1/SJ.out.tab ${output}/${sample_id}.SJ.pass1.out.tab
gzip ${output}/${sample_id}.SJ.pass1.out.tab
gzip ${output}/${prefix}SJ.out.tab
gzip ${output}/${prefix}ReadsPerGene.out.tab

## makeduplicates
module load picard/2.17.10
java -Xmx16g  -jar $EBROOTPICARD/picard.jar MarkDuplicates I=${output}/${prefix}Aligned.sortedByCoord.out.bam O=${output}/${prefix}Aligned.sortedByCoord.out.md.bam M=${output}/${prefix}Aligned.sortedByCoord.out.md_metrics.txt

## collapsed Gene Model
python3 collapse_annotation.py ../STAR-index/100bp/gencode.v19.annotation.patched_contigs.gtf ../STAR-index/100bp/gencode.v19.annotation.patched_contigs.genes.gtf
 
## quantification
rnaseqc ${index_folder}/gencode.v19.annotation.patched_contigs.genes.gtf ${output}/${prefix}Aligned.sortedByCoord.out.md.bam ${output} -s ${sample_id} -q 255 --base-mismatch 6