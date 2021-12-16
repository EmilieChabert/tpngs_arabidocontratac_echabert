# overview of the project

1) Télécharger les fichiers d'ATAQ-seq et fichiers utiles pour l'étude
Script : download data.sh 
Functions utilisées: wget lien_internet --> recupère le fichier à cette adresse internet
Les fichiers d'ATAC à télécharger sont:
* INTACT ATAC-seq data: 2019_006_S6_R1.fastq.gz et 2019_006_S6_R2.fastq.gz
* ATAC-seq data pour la racine entière : 2020_378_S8_R1.fastq.gz et 2020_378_S8_R2.fastq.gz
* ATAC-seq data pour la racine entière publiée: SRR4000472

Autres fichiers:
* Génome de référence d'A.thaliana pour le mapping depuis ENSEMBL database: Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
* Annotations du génome d'A.thaliana depuis ENSEMBL database: Arabidopsis_thaliana.TAIR10.51.gtf.gz
* Régions à conserver lors du filtering (excluant régions pouvant conduire à des artefacts): TAIR10_selectedRegions.bed
* Script pour l'analyse qualité control de l'ATAC-seq: atac_qc.sh

2) 
Script: Quality_check.sh
Entrée
Sortie 
Function
Paramètres

3) Trimming.sh

Mapping.sh

Filtering.sh

Control_quality_ATAC.sh

Analyse des données d'ATAC-seq:
Objectif: déterminer les régions ouvertes de la chromatine dans le génome d'A.thaliana

Script: Peak_calling.sh --> détecte les régions enrichies en reads dans le génome
Function: masc2 callpeak 
Paramètres: 
Sortie: 

Script: Analysis_of_ATACseq_data.sh:
Sortie: 

