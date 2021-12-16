#!/bin/bash
#
# Compute basic quality metrics for ATAC-seq data
# 


# >>> change the value of the following variables

# General variables
workingDir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert
scriptDir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert/script
outputDir=${workingDir}/processed_data/ATACseq_quality

ID=2020_374_S4.corrected # sample ID 
bam_suffix=sortedmarked_duplicatesfiltered.bam


gtf=${workingDir}/A_thaliana_genome/Arabidopsis_thaliana.TAIR10.51.gtf 
# chromosome, gene/transcript/transposon, coordonnées, gene_id, role du gene
selected_regions=${workingDir}/A_thaliana_genome/TAIR10_selectedRegions_nuc.bed
genome=${workingDir}/A_thaliana_genome/TAIR10_ChrLen.txt #info sur la longueur des chromosomes


# Variables for TSS enrichment
width=1000 # fenetre autour du TSS
flanks=100 # cote de la fenetre --> calcul couverture moyen dans le genome

# Variables for insert size distribution
chrArabido=${workingDir}/A_thaliana_genome/TAIR10_ChrLen.bed
grep -v -E "Mt|Pt" ${chrArabido} > ${workingDir}/A_thaliana_genome/TAIR10_ChrLen_1-5.bed
chrArabido=${workingDir}/A_thaliana_genome/TAIR10_ChrLen_1-5.bed 
#longueur chromosome sans mitochondrie et chloroplaste (avec start et stop)



#////////////////////// Start of the script

mkdir -p ${outputDir}

bam=${workingDir}/processed_data/filtered_data/${ID}${bam_suffix}
samtools view ${bam} | head 



# ------------------------------------------------------------------------------------------------------------ #
# --------------------------- Compute TSS enrichment score based on TSS annotation --------------------------- #
# ------------------------------------------------------------------------------------------------------------ #

#1. Define genomic regions of interest
echo "-------------------------- Define genomic regions of interest"

#definir les TSS --> enlever les mitochondries et chloroplastes,
#garder les genes codant pour des proteins
#extraire le nom du gene + sens du gene --> recuperation de la coordonnee du TSS
#creation d'un fichier avec tous les intervalles de 1000 nt autour du TSS
#bedtools --> manipulation de bam, bed

grep -v "^[MtPt]" ${gtf} | awk '{ if ($3=="gene") print $0 }'  |\
grep "protein_coding" |\
awk ' BEGIN { FS=OFS="\t" } { split($9,a,";") ; match(a[1], /AT[0-9]G[0-9]+/) ; id=substr(a[1],RSTART,RLENGTH) ; if ($7=="+") print $1,$4,$4,id,$7 ; else print $1,$5,$5,id,$7 } ' |\
uniq | bedtools slop -i stdin -g ${genome} -b ${width} > ${outputDir}/tss_${width}.bed

#enlever les intervalles qui sont dans les regions exlues dans le filtering
bedtools intersect -u -a ${outputDir}/tss_${width}.bed -b ${selected_regions} > ${outputDir}/tmp.tss && mv ${outputDir}/tmp.tss ${outputDir}/tss_${width}.bed
echo `cat ${outputDir}/tss_${width}.bed | wc -l` "roi defined from" ${gtf}

#trier les donnees en function du chromosome
sort -k1,1 -k2,2n ${outputDir}/tss_${width}.bed > ${outputDir}/tss_${width}.test

tssFile=${outputDir}/tss_${width}.test
head ${tssFile}


#2. Compute TSS enrichment
echo "-------- Compute per-base coverage around TSS"

#couverture pour chaque base dans l'intervalle --> position dans la sequence + read qui match
bedtools coverage -a ${tssFile} -b ${bam} -d -sorted > ${outputDir}/${ID}_tss_depth.txt
#sorted --> pour trier les gros fichiers

#donne les bonnes coordonees au sequence en fonction de leur orientation
awk -v w=${width} ' BEGIN { FS=OFS="\t" } { if ($5=="-") $6=(2*w)-$6+1 ; print $0 } ' ${outputDir}/${ID}_tss_depth.txt > ${outputDir}/${ID}_tss_depth.reoriented.txt
#awk -- >manipuler les tableaux en bash

#tri les donnes en function de leur position dans la sequence
sort -n -k 6 ${outputDir}/${ID}_tss_depth.reoriented.txt > ${outputDir}/${ID}_tss_depth.sorted.txt

#aditionne le nombre de matchs pour tous les TSS pour chaque position 
bedtools groupby -i ${outputDir}/${ID}_tss_depth.sorted.txt -g 6 -c 7 -o sum > ${outputDir}/${ID}_tss_depth_per_position.sorted.txt

#calcul nombre moyen de matchs pour les flancs pour normaliser les donnees
norm_factor=`awk -v w=${width} -v f=${flanks} '{ if ($6<f || $6>(2*w-f)) sum+=$7 } END { print sum/(2*f) } ' ${outputDir}/${ID}_tss_depth.sorted.txt`
echo "Nf: " ${norm_factor}

#normalise les donnes pour chaque position, centre les donees sur le TSS
awk -v w=${width} -v f=${flanks} '{ if ($1>f && $1<(2*w-f)) print $0 }' ${outputDir}/${ID}_tss_depth_per_position.sorted.txt | awk -v nf=${norm_factor} -v w=${width} 'BEGIN { OFS="\t" } { $1=$1-w ; $2=$2/nf ; print $0 }' > ${outputDir}/${ID}_tss_depth_per_position.normalized.txt

Rscript ${scriptDir}/plot_tss_enrich.R -f ${outputDir}/${ID}_tss_depth_per_position.normalized.txt -w ${width} -o ${outputDir}  



# ---------------------------------------------------------------------------------------- #
# ------------------------------- Insert size distribution ------------------------------- #
# ---------------------------------------------------------------------------------------- #

echo "-------- Compute insert size distribution"
samtools view -f 3 -F 16 -L ${chrArabido} -s 0.25 ${bam} | awk ' function abs(v){ return v < 0 ? -v : v } { print abs($9) } ' | sort -g | uniq -c | sort -k2 -g > ${outputDir}/${ID}_TLEN_1-5.txt
Rscript ${scriptDir}/plot_tlen.R -f ${outputDir}/${ID}_TLEN_1-5.txt -o ${outputDir}



# End of the script \\\\\\\\\\\\\\\\\\\\\\\\\\\\