##########################################################################################
# hreyes
# getting human data with biomaRt
# 
##########################################################################################
# always double check that you are using the datasets and versions you intend to. 
library(biomaRt)

################################ this is a crazy package #################################
#
########## normally you would do the following
# select ensembl and store to mart object.
hs.ensembl.mart <- useMart(biomart = "ENSEMBL_MART_ENSEMBL")

# then explore the available data sets and versions within the mart.
listDatasets(hs.ensembl.mart)

# locate the dataset you want to use with e.g. grep or View.
# View(.Last.value)
View(listDatasets(hs.ensembl.mart))

# finally choose your data set and store it.
hs.ensembl <- useDataset(dataset = "hsapiens_gene_ensembl", mart = hs.ensembl.mart)

########## but sometimes, and I believe it has to do with the ensembl database quering,
# the function listDatasets returns diferent results, so the safest bet is to 
# do this until you succeed: 
hs.ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl")

# if you see the error about hsapiens_gene_ensembl not being a valid name,
# just do it again until you get your hs.ensembl mart object.

#################### using listEnsembl and other data versions ####################
#
# there are a set of functions directly oriented to the most used mart
listEnsembl()

########## if you want to use the data for genome version GRCh 37.
hs37.ensembl.mart <- useEnsembl(biomart="ensembl", GRCh = 37)

# check out datasets and select human genes GRCh 37.
listDatasets(hs37.ensembl.mart)
hs37.ensembl <- useDataset(dataset = "hsapiens_gene_ensembl", mart = hs37.ensembl.mart)

########## specific Ensembl versions 
# go to the archive website
# https://www.ensembl.org/info/website/archives/index.html
# select the host from the right panel and check out marts like this:

listMarts(host = "dec2016.archive.ensembl.org")

# select ensembl and show the datasets
hs.ensembl87.mart <- useMart(biomart = "ENSEMBL_MART_ENSEMBL", host = "dec2016.archive.ensembl.org")
listDatasets(hs.ensembl87.mart)

# then, you can select your specific dataset
hs.ensembl87 <- useDataset(mart = hs.ensembl87.mart, dataset = "hsapiens_gene_ensembl")
###################################################################################
########## let's finally get some data.
# 
# A simple query, it's usually sensible to include your filter as an attribute.
getBM(attributes = c("hgnc_symbol", "ensembl_gene_id"), filters = "hgnc_symbol", values = "foxp2", mart = hs.ensembl)

########## Take a step back and check out what can be downloaded, maybe build a vector with the attributes you want.
listAttributes(hs.ensembl)
View(.Last.value)

myAttributes <- c("ensembl_gene_id", "chromosome_name", "start_position", "end_position", "transcript_count",
                  "ensembl_transcript_id", "transcript_start", "transcript_end", "transcript_length", "gene_biotype")

# you can repeat attributes, e.g. to have gene id as your first AND last column, etc.

########## explore your filters too, they can teach you how to e.g. get all the chromosome 3 genes.
listFilters(hs.ensembl)

# 'with' filters are boolean and require a TRUE or FALSE in the values field. 
# e.g. to get my attributes for ALL the data that has an HGNC symbol and kill your computer in the process
getBM(attributes = myAttributes, filters = "with_hgnc", values = TRUE, mart = hs.ensembl)

# pehaps you would prefer obtaining the hgnc symbols for all the genes in chr1, chrX and chr7.
chr_1.X.7_genes <- getBM(attributes = c("ensembl_gene_id", "chromosome_name"), filters = "chromosome_name", values = c("1", "X", "7"), mart = hs.ensembl)

########## if we have a list of ensembl gene ids and we want to retrieve specific data for them.
myGenes <- sample(chr_1.X.7_genes$ensembl_gene_id, 120)

myGenes_data <- getBM(attributes = myAttributes, filters = "ensembl_gene_id", values = myGenes, mart = hs.ensembl)

# we had 120 genes, but getBM returned a dataframe with more rows, why?
# usually because there are many transcripts per gene.
length(unique(myGenes_data$ensembl_transcript_id))
table(myGenes_data$transcript_count)

######### have fun and all that jazz
par(oma=c(1,12,1,1))
barplot(sort(table(myGenes_data$gene_biotype)), horiz = TRUE, las=1, border=F, main="Biotype of my Genes", xlab="Number of Genes")

# maybe separate into a list myGenes data by, well, gene.
split(myGenes_data, f = "ensembl_gene_id")

# ensembl doesnt provide canonical transcript annotation.
# UCSC, has available gene tables and you can use the option knownCanonical,
# http://genome.ucsc.edu/cgi-bin/hgTables
# 
# a different strategy could be to use the attribute "transcript_biotype" to filter the table.
#
# yet another criteria is using the transcript support level attribute "transcript_tsl"
# https://www.ensembl.org/Help/Glossary?id=492
#
# so short story long, if you have your ensembl transcript id, it's way easier.
#
# but while we're at it, if you use transcript data indiscriminately while doing research, I hate you.
# It's no wonder we can't reproduce most results. Fucking don't be lazy and read about the data you're using.
# Also, document properly which data you decided to use and why.
########################################################################
# e.g. go beyond human, anthropocentrism sucks! :) 
listMarts(host = "parasite.wormbase.org")
