# Projet Arabidocontratac
#Chromatin state of the organizing center of A. thaliana root meristem

Objectif: Analyse des états chromatiniens des cellules quiescentes du méristème racinaire apical de Arabidopsis thaliana
Méhtode: Récupération des cellules quiescentes de la racine par INTACT, puis réalisation d'une ATAC-seq

#Télécharger les données d'ATAQ-seq et autres fichiers nécessaires pour l'analyse
Script : download data.sh 
Fonctions utilisées: wget lien_internet --> recupère le fichier à cette adresse internet // fastq-dump --> récupérer des séquences fastq à partir de leur SRA

Les données d'ATAC téléchargés sont:
* INTACT ATAC-seq data: 2019_006_S6_R1.fastq.gz et 2019_006_S6_R2.fastq.gz
* ATAC-seq data pour la racine entière : 2020_378_S8_R1.fastq.gz et 2020_378_S8_R2.fastq.gz, 2020_374_S4.corrected.bam
* ATAC-seq data pour la racine entière publiée: SRR4000472

Autres fichiers:
* Génome de référence d'A.thaliana pour le mapping provenant de ENSEMBL database: Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
* Annotations du génome d'A.thaliana provenant de ENSEMBL database: Arabidopsis_thaliana.TAIR10.51.gtf.gz
* Régions à conserver lors du filtering (excluant régions pouvant conduire à des artefacts): TAIR10_selectedRegions.bed
* Script pour l'analyse qualité control de l'ATAC-seq: atac_qc.sh,plot_tlen.R, plot_tss_enrich.R


#Analyse de la qualité des reads de l'ATAC-seq (duplication, contenu en GC, scores de qualité)
Script: Quality_check.sh
Données d'entrée: données brutes d'ATAC-seq (fastq)
Fonctions utilisées: fastqc --> construit des graphiques montrant notamment le contenu en GC, reads dupliqués et la qualité des bases en fonction de leur position dans le read (fichier fastqc.html) // multiqc --> compile les résultats de fastqc pour toutes nos données d'ATAC-seq (multiqc_report.html)


#Trimming pour enlever les reads de mauvaises qualité et les séquences d'adapteurs
Remarque: Le trimming n'est pas forcément nécessaire au vu de la qualité de nos reads
Script: Trimming.sh
Données d'entrée: données brutes d'ATAC-seq (fastq)
Fonction utilisée: Trimmomatic
Données de sortie: nom_trimmed.fastq --> reads de bonne qualité conservés pour R1 et R2, nom_unpaired.fastq --> reads non pairés car l'un des reads a été supprimé dans R1 ou R2
Optionnel:refaire l'analyse de qualité après le trimming pour être sure que l'on a retiré les séquences de faible qualité

#Mappage des reads sur le génome d'A.thaliana
Script: Mapping.sh
* Construction d'un index du génome d'A.thaliana (Arabidopsis_thaliana.TAIR10.dna.toplevel.fa) pour que le mapping soit plus rapide
Fonctions utilisées: bowtie2-build
*Mapping
Données d'entrée: données trimmées pairés (nom_trimmed.fastq), génome indexé
Fonction utlisée: bowtie2
Sortie: Fichier bam trié
Reamarque: information sur les reads mappant à plusieurs endroits dans le terminal quand la fonction a fini de tourner
*Analyse de la distribution des reads sur les chromosomes, genome mitochondrial et genome chloroplastique
Fonctions: samtools idxstats --> donne le nombre de reads mappant sur les chromosomes ou les génomes mitochondrial et chloroplastique (3ème colonne), ainsi que les reads ne mappant pas correctement (4ème colonne)


#Filtrage des reads avec un faible score de mappage, les reads dupliqués, les reads dans les régions non chromosomiques et les régions blacklistées
Script: Filtering.sh
* Marquer les duplicats de PCR parmi les reads mappés avec $PICARD MarkDuplicates
* Exclure le génome mitochondrial et chloroplastique du génome de référence A.thaliana en utilisant grep
* Filtrer
Données d'entrée: reads mappés avec les duplicats marqués (BAM) et le génome nucléaire de référence 
Fonction utlisée: samtools view


#Contrôle qualité spécifique à l'ATAC-seq
Script: atac_qc.sh (fourni par Alice Hugues)
* Enrichissement en reads au niveau des TSS
* Taille des inserts

#Peak calling
Script: Peak_calling.sh
Fonction: masc2 callpeak --> détecte les régions enrichies en reads dans le génome
Paramètres: 
Sortie: 

#Fonctions des gènes dans les régions chromatiniennes spécifiquement ouvertes dans les cellules quiescentes 
Script: Analysis_of_ATACseq_data.sh
Sortie: 

