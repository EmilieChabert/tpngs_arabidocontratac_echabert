#Construction d'un index à partir du génome de référence --> mapping plus rapide
#workdir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert/A_thaliana_genome/
#indexdir=/home/rstudio/mydatalocal/tpngs_arabidocontratac_echabert/A_thaliana_genome/index
#mkdir -p $indexdir #creation dossier index
#cd $indexdir #nouvelle direction de travail
#bowtie2-build -f ${workdir}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa TAIR10

#Mapping the sequences on the reference genome

#mkdir -p processed_data/mapping

for trimfastq in processed_data/trim_data/*1_trimmed.fastq # for each sample

do

  suff=${trimfastq%%1_trimmed.fastq} # enlever suffixe
  prefix=${suff##processed_data/trim_data/} #enlever prefix
  filedirprefix=processed_data/trim_data/${prefix} #trouver fichier d'entrée
  outputprefix=processed_data/mapping/${prefix} #nom fichier sortie
  bowtie2 --threads 6 -x A_thaliana_genome/index/TAIR10 -1 ${filedirprefix}1_trimmed.fastq -2 ${filedirprefix}2_trimmed.fastq \
  -X 2000 --very-sensitive | samtools sort -@ 6 -O bam -o ${outputprefix}sorted.bam
  
done

# | evite la formation de nombreux fichiers intermediaires --> direct conversion et triage
# very sensitive --> mapping des petits reads
# -X 2000 --> besoin d'autoriser des grandes distances entre le debut de R1 et R2 car il peut y avoir plusieurs nucleosomes dans le fragment


