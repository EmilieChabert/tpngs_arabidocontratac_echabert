#!/bin/bash
#
# Analyse de la qualité des reads
# 

workingDir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert

#////////////////////// Start of the script
#Analysis of the read quality
mkdir ${workingDir}/processed_data/fastqc

fastqc data/*
#nombreux graphiques donnant la qualité des bases en fonction de la position dans le reads,
#qualite moyenne des reads,
#contenu GC, nombre de séquences dupliquées, contenu en adaptateurs ...

mv ${workingDir}/data/*fastqc* ${workingDir}/processed_data/fastqc

# Compile all the fastqc analysis
mkdir ${workingDir}/processed_data//multiqc_data

multiqc fastqc/*
mv ${workingDir}/multiqc_report.html ${workingDir}/processed_data//multiqc_data

# End of the script \\\\\\\\\\\\\\\\\\\\\\\\\\\\