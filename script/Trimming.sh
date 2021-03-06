#!/bin/bash
#
# Enlever les sequences de mauvaise qualite et les adapteurs
# 

workingDir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert
outputDir=${workingDir}/processed_data/trim_data

# Recuperation de la fonction Trimmomatic
ls /softwares/Trimmomatic-0.39
Trimmomatic=/softwares/Trimmomatic-0.39/trimmomatic-0.39.jar
seqadapters=/softwares/Trimmomatic-0.39/adapters/NexteraPE-PE.fa
#java -jar $Trimmomatic --> lance trimmomatic

#////////////////////// Start of the script
mkdir -p ${outputDir}

for f in ${workingDir}/data/*1.fastq # for each sample

do

  n=${f%%1.fastq} # enlever suffixe
  n=${n##data/} #enlever prefix
  prefixout=${outputDir}/${n}
  
  java -jar $Trimmomatic PE -threads 6 data/${n}1.fastq data/${n}2.fastq \
  ${prefixout}1_trimmed.fastq ${prefixout}1_unpaired.fastq ${prefixout}2_trimmed.fastq \
  ${prefixout}2_unpaired.fastq ILLUMINACLIP:${seqadapters}:2:30:10 \
  SLIDINGWINDOW:4:15 MINLEN:25
  
done

#threads 6 --> travail sur 6 coeurs
#unpaired --> fichier contenant les reads supprimes dans R1 ou R2, a ne pas utiliser pour l'analyse qui suit
#ILLUMINACLIP: Cut adapter and other illumina-specific sequences from the read
#SLIDINGWINDOW: intervalle dont on analyse la qualite -> si inferieur a une certaine qualite, on supprime la fin du read
#MINLEN: supprime les reads de moins de 25 bp

#on peut faire un fastqc pour vérifier si le trimming a bien marche
fastqc ${outputDir}/*

mkdir ${outputDir}/trim_fastqc
mv ${outputDir}/*fastqc.zip ${outputDir}/trim_fastqc
mv ${outputDir}/*fastqc.html ${outputDir}/trim_fastqc

#Compilation
mkdir ${outputDir}/trim_fastqc/multiqc_trim
multiqc ${outputDir}/trim_fastqc/*

mv ${workingDir}/multiqc_report.html ${outputDir}/trim_fastqc/multiqc_trim

# End of the script \\\\\\\\\\\\\\\\\\\\\\\\\\\\



