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


# Enlever le genome mitochondrial et chloroplastique du fichier contenant les regions a garder

grep -v -E "Mt|Pt" A_thaliana_genome/TAIR10_selectedRegions.bed > A_thaliana_genome/TAIR10_selectedRegions_nuc.bed
#grep --> cherche les chaines de caracteres
#-v tout sauf ça
# -E --> regarder les deux motifs Mt et Pt en meme temps


#Filtrer
for mapfile in processed_data/mapping/*duplicates.bam

do
  samtools view -b ${mapfile} -o ${mapfile/".bam"/"filtered.bam"} \
  -L A_thaliana_genome/TAIR10_selectedRegions_nuc.bed \
  -F 1024 -f 3 -q 30
  
      
done

#samtools view --> ouvrir les dossiers SAM
# -L A_thaliana_genome/TAIR10_selectedRegions_nuc.bed --> garder uniquement les regions de ce fichier
# -F 1024 --> enleve les reads dupliques
# -f 3 --> garde les read paired et  read mapped in proper pair
# -q 30 --> reads de qualite MAPQ > 30

mkdir -p processed_data/filtered_data
cp processed_data/mapping/*filtered.bam processed_data/filtered_data
