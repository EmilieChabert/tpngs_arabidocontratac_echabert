# Projet Arabidocontratac
#Chromatin state of the organizing center of A. thaliana root meristem

Objectif: Analyse des états chromatiniens des cellules quiescentes du méristème racinaire apical de Arabidopsis thaliana

Méthode: Récupération des cellules quiescentes de la racine par INTACT, puis réalisation d'une ATAC-seq

#Télécharger les données d'ATAQ-seq et autres fichiers nécessaires pour l'analyse
Script : download data.sh 
Fonctions utilisées: wget lien_internet --> recupère le fichier à cette adresse internet // fastq-dump --> récupérer des séquences fastq à partir de leur SRA

Les données d'ATAC téléchargées sont:
* INTACT ATAC-seq data: 2019_006_S6_R1.fastq.gz et 2019_006_S6_R2.fastq.gz
* ATAC-seq data pour la racine entière : 2020_378_S8_R1.fastq.gz et 2020_378_S8_R2.fastq.gz, 2020_374_S4.corrected.bam
* ATAC-seq data pour la racine entière publiée: SRR4000472 (SRA)
Dans la suite "nom" fait référence au nom des fichiers ci-dessus. Par exemple, 2029_006_S6_R

Autres fichiers:
* Génome de référence d'A.thaliana pour le mapping provenant de ENSEMBL database: Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
* Annotations du génome d'A.thaliana provenant de ENSEMBL database: Arabidopsis_thaliana.TAIR10.51.gtf.gz
* Régions à conserver lors du filtering (excluant régions pouvant conduire à des artefacts): TAIR10_selectedRegions.bed
* Script pour l'analyse qualité control de l'ATAC-seq fourni par Alice Hugues: atac_qc.sh,plot_tlen.R, plot_tss_enrich.R


#Analyse de la qualité des reads de l'ATAC-seq (duplication, contenu en GC, scores de qualité)
Script: Quality_check.sh
Données d'entrée: données brutes d'ATAC-seq (fastq)
Fonctions utilisées et output: fastqc --> construit des graphiques montrant notamment le contenu en GC, reads dupliqués et la qualité des bases en fonction de leur position dans le read // multiqc --> compile les résultats de fastqc pour toutes nos données d'ATAC-seq 


#Trimming pour enlever les reads de mauvaises qualité et les séquences d'adapteurs
Remarque: Le trimming n'est pas forcément nécessaire au vu de la qualité de nos reads
Script: Trimming.sh
Données d'entrée: données brutes d'ATAC-seq (fastq)
Fonction utilisée et output: Trimmomatic --> nom_trimmed.fastq contenant les reads de bonne qualité conservés pour R1 et R2, nom_unpaired.fastq contenant  les reads non pairés car l'un des reads a été supprimé dans R1 ou R2
Optionnel:refaire l'analyse de qualité après le trimming pour être sûre que l'on a retiré les séquences de faible qualité

#Mappage des reads sur le génome d'A.thaliana
Script: Mapping.sh
1. Construction d'un index du génome d'A.thaliana (Arabidopsis_thaliana.TAIR10.dna.toplevel.fa) pour que le mapping soit plus rapide
Fonction utilisée: bowtie2-build

2. Mapping
Données d'entrée: données trimmées pairés (nom_trimmed.fastq) + génome indexé
Fonction utlisée et output: bowtie2 --> fichier bam trié contenant notamment la position des reads sur le génome
Remarque: noter les informations qui sont données dans le terminal lorsque la fonction a finie de tourner --> Nombre de reads mappant à plusieurs localisations et si la localisation des reads pairés est cohérente

3. Analyse de la distribution des reads sur les chromosomes, genome mitochondrial et genome chloroplastique
Fonction utilisée: samtools idxstats --> donne le nombre de reads mappant sur les chromosomes ou les génomes mitochondrial et chloroplastique (3ème colonne), ainsi que les reads ne mappant pas correctement (4ème colonne)


#Filtrage des reads avec un faible score de mappage, les reads dupliqués, les reads dans les régions non chromosomiques et les régions blacklistées
Script: Filtering.sh
1. Marquer les duplicats de PCR parmi les reads mappés (nomsorted.bam) avec $PICARD MarkDuplicates
2. Exclure le génome mitochondrial et chloroplastique du génome de référence A.thaliana en utilisant grep
3. Filtrer
Données d'entrée: reads mappés avec les duplicats marqués (BAM) + génome nucléaire de référence 
Fonction utlisée et ouutput: samtools view (fonction permettant de manipuler les fichiers BAM et d'enlever ou conserver certains flags --> ex:1024 = reads dupliqués) --> fichier BAM contenant les reads uniques mappant correctement sur le génome nucléaire de A.thaliana: nomsortedmarked_duplicatesfiltered.bam


#Contrôle qualité spécifique à l'ATAC-seq
Cette analyse est sépcifique de l'ATAC-seq. On la réalise pour montrer que la manipulation d'ATAC-seq a été techniquement correctement réalisé.
Script: atac_qc.sh (fourni par Alice Hugues)
* Enrichissement en reads au niveau des TSS: il existe une zone au niveau des TSS qui ne contient pas de nucléosomes. On devrait donc avoir un enrichissement relatif en reads dans cette région.
1. Création d'un fichier contenant les coordonnées des intervalles de 1000 bp autour des TSS en utilisant grep et bedtools --> tss_1000.bed = chromosome, intervalle, gène associé au TSS, direction du gène
2. Identification des reads mappant pour chaque position de l'intervalle
Données d'entrée: reads filtrés (nomsortedmarked_duplicatesfiltered.bam) + fichier cotenant les intervalles (tss_1000.bed)
Fonction utilisée: bedtools coverage --> fichier donnant pour chaque intervalle le nombre de reads mappant pour chaque position de l'intervalle (nom_tss_depth.txt) 
Important: Il faut réorienter les positions dans le fichier précédent en fonction de l'orientation du gène avant d'ajouter tous les reads mappant pour chaque position autour du TSS 
3. Calcul de l'enrichissement
Fonction utilisée: bedtools groupby --> ajoute les reads mappant pour chaque position
Important: normaliser les données avec la couverture au niveau des flancs
Fichier de sortie: nom_tss_depth_per_position.normalized.txt
4. Visualisation du ficher txt en utilisant le script plot_tss_enrich.R --> graphique donnant la couverture normalisée en fonction de la position par rapport au TSS

* Taille des inserts: la transposase coupe dans les régions accessible de la chromatine. On devrait par conséquent observer des petits inserts (distantce entre deux reads pairés) et si la transposase coupe de part et d'autre de nucléosomes des inserts de taille proportionnelles au 145 nucléotides autour de chaque nucléosomes
Calcul de la distance entre les reads pairés en manipulant le fichier BAM avec samtools view et awk (nom_TLEN_1-5.txt)
Visualisation en utilisant le script plot_tlen.R donnant la densité en fonction de la taille des inserts

#Identification des régions de la chromatine ouvertes dans le génome
Nous avons utilisé la méthode du peak calling pour identifier les régions ouvertes de la chromatine. Les régions ouvertes de la chromatine sont plus accessible pour la transposase et sont donc enrichies en reads. Le peak calling donne les régions où une forte fréquence de reads ont mappés (pics). 

Script: Peak_calling.sh
Fonction et output: masc2 callpeak --> plusieurs fichiers, en particulier .broadPeak contient la localisation des pics (chromossome + intervalles + taille) et des informations statistiques comme la pvalue
La visualisation des pics (fichier .broadPeak) se fait sur IGV (Integrative Genomics Viewer). Télécharger également les données filtrées au préalable indexer pour visualiser les reads et leurs fréquences sur le génome (.2019_006_S6_Rsortedmarked_duplicatesfiltered)

#Fonctions des gènes dans les régions chromatiniennes spécifiquement ouvertes dans les cellules quiescentes
Script: Analysis_of_ATACseq_data.sh

1. Filtrage du génome de référence
Nous n'avons retenu que les annotations concernant les gènes nucléaires

2. Identification des gènes les plus proches des pics
Données d'entrée: pics d'enrichissement en reads identifiés lors du peak calling + génome de référence filtré
Fonction utilisé et output: bedtools closest --> associe à chaque pic le nom du gène le plus proche et indique également la distance entre le pic et le gène (une distance de 0 signifie que le pic et le gène s'overlappent)

3. Identification des pics présent uniquement dans les cellules quiescents
Fonction utilisé et output: bedtools intersect (compare les pics présent dans les données d'ATAC-seq des cellules quiescentes et les données sur la racine entière) --> liste des pics uniques aux cellules quiescentes
Pour la suite de l'analyse nous avons choisi de sélectionner uniquement les pics présent dans au moins deux sur trois des sets de données sur les cellules quiescentes en utilisant le script Analyse_compatison.R (.quiescentcells.unique.common.peaks.treated.txt)

4. Identification des gènes présentant une chromatine plus ouverte dans les cellules quiescentes
Nous avons sélectionner les pics overlappant avec les gènes, c'est-à-dire présentant une distance égale à 0 (script Analysis_comparison.R). A noter que ce critère sélectionne différents cas de figure: un pic overlappant avec le début, le corps ou la fin du gène. Le mieux serait de sélectionner uniquement les pics se situant proche du TSS. Mais par manque de temps, nous avons continué avec ces données tout en sachant que la sélection était imparfaite (quiescentcells.unique.common.peaks.distance0.txt) 

Nous avons utilisé geneontology pour analyser les fonctions des gènes trouvés. Pour comparer, nous avons effectué le même traitement sur les données de racine entière et identifié les gènes présentant des pics non présentant dans les cellules quiescentes



