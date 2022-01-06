#!/bin/bash

# General variables
workingDir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert
outputDir=${workingDir}/processed_data/Analysis


#////////////////////// Start of the script

mkdir -p ${outputDir}

#Filtrage du génome
gtf=${workingDir}/A_thaliana_genome/Arabidopsis_thaliana.TAIR10.51.gtf
#filtrer les annotations --> genes nucleaires, garder uniquement les genes (tous)
#extraire le nom du gene
gtf_filtered=${gtf/.gtf/.filtered.gtf}
grep -v "^[MtPt]" ${gtf} | awk '{ if ($3=="gene") print $0 }' |\
awk ' BEGIN { FS=OFS="\t" } { split($9,a,";") ; match(a[1], /AT[0-9]G[0-9]+/) ; id=substr(a[1],RSTART,RLENGTH) ; print $1,$4,$5,id,$7 }' |\
sort -k1,1 -k2,2n > ${gtf_filtered}

#determination des genes les plus proches des pics de reads
for ID in ${workingDir}/processed_data/Peak_calling/*broadPeak

do
name=${ID##${workingDir}/processed_data/Peak_calling/}
name=${name%%peaks.broadPeak} 

bedtools closest -a ${ID} -b ${gtf_filtered} -D ref > ${outputDir}/${name}.nearest.genes.txt 
#-D ref --> donne l'information de la distance entre le pic et le gene

done

#intersection des pics de reads entre la racine entiere et les cellules quiescents
racine=${workingDir}/processed_data/Peak_calling/2020_374_S4.corrected_peaks.broadPeak
quiescent=${workingDir}/processed_data/Peak_calling/2019_007_S7_R_peaks.broadPeak

racinename=${racine##${workingDir}/processed_data/Peak_calling/}
racinename=${racinename%%.corrected_peaks.broadPeak}

quiescentname=${quiescent##${workingDir}/processed_data/Peak_calling/}
quiescentname=${quiescentname%%peaks.broadPeak}

bedtools intersect -a ${quiescent} -b ${racine} -v > ${outputDir}/${quiescentname}${racinename}comparaison.broadpeaks.txt 
#v --> retourne uniquement les pics present dans a et pas dans b


# ------------------------------------------------------------------------------------------------------------ #
# --------------------------- Pics uniques communs aux trois echantillons --------------------------- #
# ------------------------------------------------------------------------------------------------------------ #

sample1=${outputDir}/2019_006_S6_R_2020_374_S4comparaison.broadpeaks.txt
sample2=${outputDir}/2019_007_S7_R_2020_374_S4comparaison.broadpeaks.txt
sample3=${outputDir}/2020_372_S2_R_2020_374_S4comparaison.broadpeaks.txt

touch ${outputDir}/quiescentcells.common.peaks.txt #creer fichier vide
#creation d'un fichier avec tous les pics uniques au cellules quiescents
cat ${sample1} >> ${outputDir}/quiescentcells.common.peaks.txt
cat ${sample2} >> ${outputDir}/quiescentcells.common.peaks.txt
cat ${sample3} >> ${outputDir}/quiescentcells.common.peaks.txt

#trier en fonction du chromosome et de la position du pic
sort -k1,1 -k2,2n ${outputDir}/quiescentcells.common.peaks.txt > ${outputDir}/quiescentcells.common.peaks.sorted.txt

#merge les pics qui s'overlappent
bedtools merge -i ${outputDir}/quiescentcells.common.peaks.sorted.txt -c 4 -o "collapse","count_distinct"> ${outputDir}/quiescentcells.unique.common.peaks.txt 
#c --> conserve le nom du pic
#count_distinct --> nombre de pic rassembles (1,2,3)

#Voir script R Analysis_comparison pour le traitement de ce fichier 
# --> fichier quiescentcells.unique.common.peaks.treated.txt avec les pics communs à au moins deux echantillons

# ------------------------------------------------------------------------------------------------------------ #
# --------------------------- Annotations genes pics uniques des cellules quiescentes  --------------------------- #
# ------------------------------------------------------------------------------------------------------------ #

bedtools closest -a ${outputDir}/quiescentcells.unique.common.peaks.treated.txt -b ${gtf_filtered} -D a > ${outputDir}/quiescentcells.unique.common.peaks.nearest.genes.txt 
#-D --> distance genes et pics, precise si le pic est avant ou apres le gene

#Voir script R Analysis_comparison pour la sélection des pics qui overlappent avec les gènes

# ------------------------------------------------------------------------------------------------------------ #
# --------------------------- Pics uniques au racine entiere  --------------------------- #
# ------------------------------------------------------------------------------------------------------------ #
racine=${workingDir}/processed_data/Peak_calling/2020_374_S4.corrected_peaks.broadPeak
quiescenttot=${workingDir}/processed_data/Analysis/quiescentcells.unique.common.peaks.treated.txt

racinename=${racine##${workingDir}/processed_data/Peak_calling/}
racinename=${racinename%%.corrected_peaks.broadPeak}

bedtools intersect -a ${racine} -b ${quiescenttot} -v > ${outputDir}/${racinename}.unique.peaks.txt 

bedtools closest -a ${outputDir}/${racinename}.unique.peaks.txt -b ${gtf_filtered} -D a > ${outputDir}/${racinename}.unique.peaks.nearest.genes.txt 

# End of the script \\\\\\\\\\\\\\\\\\\\\\\\\\\\

