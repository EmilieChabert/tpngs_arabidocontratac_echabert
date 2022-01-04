#!/bin/bash
#
# Mappage des reads sur le genome de A.thaliana
# 

### 1. Construction d'un index à partir du génome de référence --> mapping plus rapide
workdir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert/A_thaliana_genome/
indexdir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert/A_thaliana_genome/index
mkdir -p ${indexdir} #creation dossier index
cd ${indexdir} #nouvelle direction de travail
bowtie2-build -f ${workdir}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa TAIR10 #création d'un bowtie2 index database

workingDir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert
outputDir=${workingDir}/processed_data/mapping
cd ${workingDir}
#////////////////////// Start of the script

### 2. Mapping the reads on the reference genome

mkdir -p ${outputDir}

for trimfastq in processed_data/trim_data/*1_trimmed.fastq # for each sample

do

  suff=${trimfastq%%1_trimmed.fastq} # enlever suffixe
  prefix=${suff##processed_data/trim_data/} #enlever prefix
  filedirprefix=processed_data/trim_data/${prefix} #trouver fichier d'entrée
  outputprefix=${outputDir}/${prefix} #nom fichier sortie
  
  bowtie2 --threads 6 -x A_thaliana_genome/index/TAIR10 -1 ${filedirprefix}1_trimmed.fastq -2 ${filedirprefix}2_trimmed.fastq \
  -X 2000 --very-sensitive | samtools sort -@ 6 -O bam -o ${outputprefix}sorted.bam
  
done

# very sensitive --> mapping des petits reads
# -X 2000 --> besoin d'autoriser des grandes distances entre le debut de R1 et R2 car il peut y avoir plusieurs nucleosomes dans le fragment
# | evite la formation de nombreux fichiers intermediaires --> conversion directe en fichier bam et triage


### 3. Analyse de la distribution des reads sur les chromosomes, genome mitochondrial et genome chloroplastique
for bamfile in ${outputDir}/*sorted.bam
do 
  echo ${bamfile}
  #samtools index ${bamfile}
  samtools idxstats ${bamfile}
done
#plus rapide si samtools idstats utilise un index 
#Sortie --> reference sequence name, sequence length, mapped read-segments and unmapped read-segments

# End of the script \\\\\\\\\\\\\\\\\\\\\\\\\\\\