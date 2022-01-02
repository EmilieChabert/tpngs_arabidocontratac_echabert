#Selectionner les pics communs a au moins deux echantillons
data=read.table(file="processed_data/Analysis/quiescentcells.unique.common.peaks.txt")
nrow(data)
nrow(data[data$V5>=2,])
datacommonpeak=subset(data,data$V5>=2)
nrow(datacommonpeak)
View(datacommonpeak)

write.table(datacommonpeak,file="processed_data/Analysis/quiescentcells.unique.common.peaks.treated.txt",row.names=FALSE,col.names=FALSE,sep="\t",quote=FALSE)

#Selectionner les pics avec une distance egale a 0 des genes
data1=read.table(file="processed_data/Analysis/quiescentcells.unique.common.peaks.nearest.genes.txt")
View(data1)
hist(log(abs(data1$V11)))
datapeakgene=subset(data1,data1$V11==0)
View(datapeakgene)
nrow(datapeakgene)
write.table(datapeakgene,file="processed_data/Analysis/quiescentcells.unique.common.peaks.distance0.txt",row.names=FALSE,col.names=FALSE,sep="\t",quote=FALSE)

#Selectionner les pics avec une distance egale a 0 des genes pour la racine entiere
dataracine=read.table(file="processed_data/Analysis/2020_374_S4.unique.peaks.nearest.genes.txt")
View(dataracine)
hist(log(abs(dataracine$V11)))
datageneracine=subset(dataracine,dataracine$V15==0)
View(datageneracine)
nrow(datageneracine)
write.table(datageneracine,file="processed_data/Analysis/2020_374_S4.unique.peaks.distance0.txt",row.names=FALSE,col.names=FALSE,sep="\t",quote=FALSE)
