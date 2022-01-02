#!/bin/bash
#
# Téléchargement des données et scripts nécessaire à l'analyse de l'ATAC-seq
# 

#////////////////////// Start of the script

#download INTACT ATAC-seq data
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/Data/2019_006_S6_R1.fastq.gz
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/Data/2019_006_S6_R2.fastq.gz
#wget --> télécharger des données depuis une page internet

#download ATAC-seq data all root
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/Data/2020_378_S8_R1.fastq.gz
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/Data/2020_378_S8_R2.fastq.gz
mv *fastq.gz  data

#download publicly available ATAC-seq data
#GSM2260235: Col-0_50k_root_nuclei_FANS-ATAC-seq_rep1; Arabidopsis thaliana; OTHER(SRR4000472)
fastq-dump --split-files SRR4000472
mv *fastq data

#download reference genome and annotations from  ENSEMBL database
mkdir A_thaliana_genome #création d'un fichier

wget http://ftp.ebi.ac.uk/ensemblgenomes/pub/release-51/plants/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
wget http://ftp.ebi.ac.uk/ensemblgenomes/pub/release-51/plants/gtf/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.51.gtf.gz
mv *gz A_thaliana_genome

gunzip A_thaliana_genome/Arabidopsis_thaliana.TAIR10.51.gtf.gz # Dézipper
gunzip A_thaliana_genome/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
gunzip data/*

#download regions of the genome that can induce a bias in the analysis
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/Supporting_files/TAIR10_selectedRegions.bed
mv *bed A_thaliana_genome

#Download the scripts for the control quality of the ATAC-seq
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/arabidocontratac/Scripts/atac_qc.sh
mv atac_qc.sh script

wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/arabidocontratac/Scripts/plot_tlen.R
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/arabidocontratac/Scripts/plot_tss_enrich.R
mv plot_tlen.R script
mv plot_tss_enrich.R script

wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/arabidocontratac/Supporting_files/TAIR10_ChrLen.bed
mv TAIR10_ChrLen.bed A_thaliana_genome
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/arabidocontratac/Supporting_files/TAIR10_ChrLen.txt
mv TAIR10_ChrLen.txt A_thaliana_genome

#Téléchargement du nouveau fichier racine entiere filtre
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/arabidocontratac/Data/2020_374_S4.corrected.bam
mv 2020_374_S4.corrected.bam processed_data/filtered_data
 
# End of the script \\\\\\\\\\\\\\\\\\\\\\\\\\\\