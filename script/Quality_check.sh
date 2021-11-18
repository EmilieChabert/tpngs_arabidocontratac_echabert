#Analysis of the read quality
fastqc data/*
mv ./data/*fastqc* fastqc
mv ./fastqc processed data

# Compile all the fastqc analysis
multiqc fastqc/*
mv ./multiqc_report.html multiqc_data
mv ./multiqc_data processed data
