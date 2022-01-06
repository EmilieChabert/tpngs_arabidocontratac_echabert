#!/bin/bash
#
# Peak_calling
# 

workingDir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert
outputDir=${workingDir}/processed_data/Peak_calling

#////////////////////// Start of the script
mkdir -p ${outputDir}

for ID in ${workingDir}/processed_data/filtered_data/*filtered.bam

do
name=${ID##${workingDir}/processed_data/filtered_data/}
name=${name%%sortedmarked_duplicatesfiltered.bam} 

macs2 callpeak -t ${ID} -n $name -q 0.01 --outdir ${outputDir} -q 0.01 --nomodel --shift -25 --extsize 50 --keep-dup "all" -B --broad --broad-cutoff 0.01 -g 10E7

done
#nomodel --> pas le modele du CHIP
# broad --> regroupe les pics
#broad cutoff --> paramètre pour le regroupement
#q --> valeur limite pour la détection des pics
#g --> taille du genome d'Arabidospsis

##Indexer les fichers filtered.bam pour le visualisation sur IGV
for ID in ${workingDir}/processed_data/filtered_data/*filtered.bam
do 
samtools index ${ID}
done

# End of the script \\\\\\\\\\\\\\\\\\\\\\\\\\\\