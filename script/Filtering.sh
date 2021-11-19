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


# Enlever le genome mitochondrial et chloroplastique

grep -v -E "Mt|Pt" A_thaliana_genome/TAIR10_selectedRegions.bed > A_thaliana_genome/TAIR10_selectedRegions_nuc.bed
#sélectionne les deux lignes contenant termes/ -v tout sauf ça


#Filtrer
for mapfile in processed_data/mapping/*duplicates.bam

do
  samtools view -b ${mapfile} -o ${mapfile/".bam"/"filtered.bam"} \
  -L A_thaliana_genome/TAIR10_selectedRegions_nuc.bed \
  -F 1024 -f 3 -q 30
  
      
done

# -L A_thaliana_genome/TAIR10_selectedRegions_nuc.bed --> enlever le genome mitochondrial et chloroplastique
# -F 1024 --> enleve les reads dupliques
# -f 3 --> garde les read paired et  read mapped in proper pair
# -q 30 --> reads de qualite MAPQ > 30
