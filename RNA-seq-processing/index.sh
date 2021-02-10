STAR --runMode genomeGenerate \
     --genomeDir ./ \
     --genomeFastaFiles ./Homo_sapiens_assembly19.fasta  \
     --sjdbGTFfile ./gencode.v19.annotation.patched_contigs.gtf  \
     --sjdbOverhang 154 \
     --runThreadN 16