#download INTACT ATAC-seq data
wget --user='tp_ngs' --password='Arabido2021!' https://flower.ens-lyon.fr/tp_ngs/Data/

#download publicly available ATAC-seq data
#GSM2260235: Col-0_50k_root_nuclei_FANS-ATAC-seq_rep1; Arabidopsis thaliana; OTHER(SRR4000472)
fastq-dump SRR4000472

