#Enlever le genome non chromosomique
#reads qui ont pas mapper
# reads de mauvaise qualite 
#regions blacklistees
# reads dupliques

#Marquer les duplicats de PCR
for mapfile in processed_data/mapping/*bam

do
  java -jar $PICARD MarkDuplicates \
      I=${mapfile} \
      O=${mapfile/".bam"/"marked_duplicates.bam"} \
      M=${mapfile/".bam"/"marked_dup_metrics.txt"}
      
done

#for mapfile in processed_data/mapping/*bam
#do

#samtools view -b

#done

#-b --> output in the BAM format
