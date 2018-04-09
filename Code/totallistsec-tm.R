#################
# Author: Maggie Shaw
# Date Created: 06Feb2018
# Latest Edit: 28Mar2018
# Purpose: Read in Sec/TM data from databases
#################

################
# Libraries Used
library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(DataCombine)
library(openxlsx)
# plyr also used but had to wait until it was needed to call or dplyr commands would error
################

## Important Notes ##
# See README for how data was obtained for each source and the files needed prior to running the code
# Basic Structure of Code:
## 1. Read in data from each source
## 2. Parse out unnessicary columns, typically keep protein names/accession numbers, localization, confidence scores.
## 3. Seperate or search for Sec/TM specific localization terms in dataframe if source did not allow for query before downlaod
## (for accession numbers) 4. Querey using Uniprot search tool (see README) and download results. 
## 5. Leave column with protein name ("Protein_Name") and given confidence score or add column with Score of 1. ("~source~.score")
## 6. Make list with all Secreted results and another with all Transmembrane results
## 7. Give all NA values a value of 0, scale confidence score on scale of 0 - 1, remove non-scaled score columns
## 8. Create golden standard list from results on PDB 
## 9. Save lists as .tsv files for statistical analysis

#-----------------------------------------------------#
# 1) ORGANELLE DB
# Query on site for correct localization for transmembrane 
organelleDB.fulldata <- read.csv("OrganelleDBresults.txt", skip = 1, header = FALSE , sep = "\t")
# Only need protein names
organelleDB.fulldata[ ,which(names(organelleDB.fulldata) %in% c("V3"))] -> organelleDB.fulldata
as.data.frame(organelleDB.fulldata) -> organelleDB.trans
# Column names got pushed to 2nd row of dataframe, delete 1st column
organelleDB.trans = organelleDB.trans[-1,]
as.data.frame(organelleDB.trans) -> organelleDB.trans
# No score given so all entries get score of 1 and results column always set to "Protein_Name"
organelleDB.trans %>% mutate(OrganelleDB.Score = 1) -> organelleDB.trans
colnames(organelleDB.trans)[1] <- "Protein_Name"


#-----------------------------------------------------#
#2) COMPARTMENTS -- 4 channels of data
# Read in URL, find correct localization, and get average confidence score for each protein. Creates one list for transmembrane and one for secreted.
compartments <- function(my_url, column_names, new_names){
  compartments_data <- read.csv(my_url, sep = "\t", header = FALSE)
  compartments_data[ , -which(names(compartments_data) %in% column_names)] -> data.1
  colnames(data.1) <- c(new_names)
  
 # Transmembrane
  data.1 %>% filter(grepl("Plasma membrane|Cell surface", Localization)) -> data.trans

  # Mean confidence score for duplicated proteins in the list
  data.trans %>% group_by(Protein_Name) %>% summarise(mean(Score)) -> data.trans.mean
  
  # Secreted
  data.1 %>% filter(grepl("Extracellular", Localization)) -> data.secr
  data.secr %>% group_by(Protein_Name) %>% summarise(mean(Score)) -> data.secr.mean
  
  return (list(data.trans.mean, data.secr.mean))
  
}

outlist1 <- compartments("http://download.jensenlab.org/human_compartment_knowledge_full.tsv", c("V1", "V3", "V5", "V6"), c("Protein_Name", "Localization", "Score"))  
outlist2 <- compartments("http://download.jensenlab.org/human_compartment_experiments_full.tsv", c("V1", "V3", "V5", "V6"), c("Protein_Name", "Localization", "Score"))
outlist3 <- compartments("http://download.jensenlab.org/human_compartment_textmining_full.tsv", c("V1", "V3", "V5", "V7"), c("Protein_Name", "Localization", "Score"))
outlist4 <- compartments("http://download.jensenlab.org/human_compartment_predictions_full.tsv", c("V1", "V3", "V5", "V6"), c("Protein_Name", "Localization", "Score"))

# Function to unlist for each knowledge channel and average each Proteins confidence scores for trans/secreted across all 4 channels
unlistn_score <- function(n){

  as.data.frame(outlist1[n]) -> outlist1_
  as.data.frame(outlist2[n]) -> outlist2_
  as.data.frame(outlist3[n]) -> outlist3_
  as.data.frame(outlist4[n]) -> outlist4_

  # joins knowledge channels by protein name
  left_join(outlist1_ , outlist2_, by = "Protein_Name") %>%
    left_join(., outlist3_, by = "Protein_Name") %>%
      left_join(., outlist4_, by = "Protein_Name") -> compartments_
  
  # all "NA" values are set to 0. If the channel did not come up with a result for that protein it is considered a score of 0 
  compartments_[is.na(compartments_)] <- 0
  # mean score for each protein between all 4 channels is considered the overall confidence score
  compartments_ %>% mutate(average_score = rowMeans(.[,2:5])) -> compartments_

  compartments_[, -which(names(compartments_) %in% c("mean.Score..x", "mean.Score..y", "mean.Score..x.x", "mean.Score..y.y"))] -> compartments_
  

  
  return(list(compartments_))
  
}
# Need to make 2 lists. From last function "1" is the transmembrane proteins, "2" contains the secreted

compartments_trans <- unlistn_score(1)
compartments_secr <- unlistn_score(2)
# Final data frames with scaled scores
as.data.frame(compartments_trans) -> compartments_trans
colnames(compartments_trans)[2] <- "compartments.Score"
as.data.frame(compartments_secr) -> compartments_secr
colnames(compartments_secr)[2] <- "compartments.Score"

#-----------------------------------------------------#
# 3) Protein Atlas
# Results were downloaded via instructions and read into here:

proteinatlas.fulldata <- read.table("subcellular_location.tsv", header = TRUE, sep = "\t")
proteinatlas.fulldata[, -which(names(proteinatlas.fulldata) %in% c("Gene", "Enhanced", "Supported", "Approved", "Uncertain",  "Cell.cycle.dependency", "Single.cell.variation.intensity", "Single.cell.variation.spatial"))] -> proteinatlas.fulldata

proteinatlas.fulldata %>% filter(grepl('Cell Junctions|Vesicles', GO.id)) -> proteinatlas.secr
proteinatlas.fulldata %>% filter(grepl('Plasma membrane', GO.id)) -> proteinatlas.trans

PAscoren_list <- function(protein.dat){
  protein.dat %>% mutate(Proteinatlas.Score = case_when(Reliability == "Uncertain" ~ 1,
                                          Reliability == "Approved" ~ 2,
                                          Reliability == "Supported" ~ 4,
                                          Reliability == "Enhanced" ~ 4)) -> protein.dat
 
  # NORMALIZE COMMAND -- COME BACK TO THIS
  # protein.dat <- transform(protein.dat, normalized_score = (protein.dat$Score - min(protein.dat$Score))/(max(protein.dat$Score) - min(protein.dat$Score)))
  protein.dat[, -which(names(protein.dat) %in% c("Reliability","GO.id"))] -> protein.dat
  colnames(protein.dat)[1] <- "Protein_Name"
  
  return(list(protein.dat))
}

# Call function and create final list
proteinatlas.secr <- PAscoren_list(proteinatlas.secr)
proteinatlas.secr <- as.data.frame(proteinatlas.secr)

proteinatlas.trans <- PAscoren_list(proteinatlas.trans)
proteinatlas.trans <- as.data.frame(proteinatlas.trans)


#-----------------------------------------------------#
# 4) Cell Surface Proteins - CSPA Validated Proteins
# Results downloaded on database website 
# Transmembrane only -- all validated cell surface proteins, no need to grab terms
CSPA.list <- read.xlsx("S2_File.xlsx", sheet = 1)
CSPA.list[, which(names(CSPA.list) %in% c("ENTREZ.gene.symbol", "protein.probability"))] -> CSPA.list
colnames(CSPA.list)[1] <- "Protein_Name"
colnames(CSPA.list)[2] <- "CSPA.Score"


#-----------------------------------------------------#
# 5) LifeDB
# Results were downloaded and changed to tsv format via instructions
LifeDB.fulldata <- read.csv("LifeDB.tsv", header = TRUE, sep = "\t")
LifeDB.fulldata[ , -which(names(LifeDB.fulldata) %in% c("ParentCloneID", "EntryCloneID", "X", "NCBI", "ProteinLocalization"))] -> LifeDB.fulldata
LifeDB.fulldata %>% filter(grepl('plasma membrane', UCSU)) -> LifeDB.trans
# No Secreted/ Extracellular term for LifeDB
# No score given so anything said to be trans gets score of 1
LifeDB.trans %>% mutate(LifeDB.Score = 1) -> LifeDB.trans
LifeDB.trans[, -which(names(LifeDB.trans) %in% c("UCSU"))] -> LifeDB.trans
colnames(LifeDB.trans)[1] <- "Protein_Name"


#-----------------------------------------------------#
#### FUNCTION NEEDED FOR 6 AND 7 ####
uniprot.resultnscore <- function(uniprot.results.file){
  # Uniprot accessions uploaded to here -> http://www.uniprot.org/uploadlists/ -- Must convert UniprotKB AC/ID to UniprotKB ID
  # Reseults downloaded and list of Proteins isolated
  uniprotresults <- read.delim(uniprot.results.file, header = TRUE, sep = "\t")
  uniprotresults %>% mutate(Gene.names = strsplit(as.character(Gene.names), " ")) %>% unnest(Gene.names) -> uniprotresults 
  uniprotresults %>% mutate(Gene.names = strsplit(as.character(Gene.names), "/")) %>% unnest(Gene.names) -> uniprotresults
  as.data.frame(uniprotresults$Gene.names) -> uniprotresults
  colnames(uniprotresults)[1] <- "Protein_Name"
  uniprotresults %>% mutate(Score = 1) -> uniprotresults
  uniprotresults %>% group_by(Protein_Name) %>% distinct() -> uniprotresults
  
  return(list(uniprotresults))
}
#####################################
#-----------------------------------------------------#
# 6) LOCATE
# Results were downloaded and changed to tsv format via instructions
LOCATE.fulldata <- read.table("LOCATE_human_v6_20081121.tsv", header = TRUE, sep = "\t")
as.data.frame(LOCATE.fulldata$accn) -> LOCATE.test
write.table(LOCATE.test, "LOCATE.test.tsv", quote = FALSE, sep = '\t',col.names = NA)


LOCATE.list <- function(LOCATE.terms, accn_group){

  LOCATE.fulldata %>% filter(grepl(LOCATE.terms, class)) -> LOCATE.newlist
  as.data.frame(LOCATE.newlist$accn) -> LOCATE.newlist
  colnames(LOCATE.newlist)[1] <- "Protein_Name"
  
  LOCATE.newlist %>% filter(str_detect(Protein_Name, accn_group)) -> LOCATE.newlist
  

  return(list(LOCATE.newlist))
}


# For Ensembl ID's, produces files to use in search on Uniprot
LOCATE.list('secretome',"^EN") -> LOCATE.secr.ens
as.data.frame(LOCATE.secr.ens) -> LOCATE.secr.ens
write.table(LOCATE.secr.ens, "LOCATE.secr.ens.tsv", quote = FALSE, sep = "\t", col.names = NA)

LOCATE.list('mtmp|typeI|typeII',"^EN") -> LOCATE.trans.ens
as.data.frame(LOCATE.trans.ens) -> LOCATE.trans.ens
write.table(LOCATE.trans.ens, "LOCATE.trans.ens.tsv", quote = FALSE, sep = '\t',col.names = NA)

# Use uniprot-function -- ON SITE : Must convert "Entrez(Gene ID)" to "UniprotKB" 
uniprot.resultnscore("ens.LOCATE.secr.results.tab") -> LOCATE.secr.ens
as.data.frame(LOCATE.secr.ens) -> LOCATE.secr.ens

uniprot.resultnscore("ens.LOCATE.trans.results.tab")-> LOCATE.trans.ens
as.data.frame(LOCATE.trans.ens) -> LOCATE.trans.ens


# For ref-seq ID's
LOCATE.list('secretome',"^NP_") -> LOCATE.secr.ref
as.data.frame(LOCATE.secr.ref) -> LOCATE.secr.ref
write.table(LOCATE.secr.ref, "ref.LOCATE.secr.tsv", quote = FALSE, sep = "\t", col.names = NA)

LOCATE.list('mtmp|typeI|typeII', "^NP_") -> LOCATE.trans.ref
as.data.frame(LOCATE.trans.ref) -> LOCATE.trans.ref
write.table(LOCATE.trans.ref, "ref.LOCATE.trans.tsv", quote = FALSE, sep = '\t',col.names = NA)

# Use uniprot-function -- ON SITE : Must convert "Refseq Protein" to "UniprotKB" 
uniprot.resultnscore("ref.LOCATE.secr.results.tab") -> LOCATE.secr.ref
as.data.frame(LOCATE.secr.ens) -> LOCATE.secr.ref

uniprot.resultnscore("ref.LOCATE.trans.results.tab")-> LOCATE.trans.ref
as.data.frame(LOCATE.trans.ref) -> LOCATE.trans.ref

# Function to grab other kinds of accession numbers
LOCATE.everythingelse <- function(LOCATE.terms){
  LOCATE.fulldata %>% filter(grepl(LOCATE.terms, class)) -> LOCATE.other
  as.data.frame(LOCATE.other$accn) -> LOCATE.other

  return(list(LOCATE.other))
}

# For everything else
LOCATE.everythingelse('secretome') -> LOCATE.secr.other
as.data.frame(LOCATE.secr.other) -> LOCATE.secr.other
write.table(LOCATE.secr.other, "other.LOCATE.secr.tsv", quote = FALSE, sep = '\t',col.names = NA)


LOCATE.everythingelse('mtmp|typeI|typeII') -> LOCATE.trans.other
as.data.frame(LOCATE.trans.other) -> LOCATE.trans.other
write.table(LOCATE.trans.other, "other.LOCATE.trans.tsv", quote = FALSE, sep = '\t',col.names = NA)

# Use uniprot-function -- ON SITE : Must convert "EMBL/GenBank/DDBL CDS" to "UniprotKB" 
uniprot.resultnscore("ens.LOCATE.secr.results.tab") -> LOCATE.secr.other
as.data.frame(LOCATE.secr.other) -> LOCATE.secr.other

uniprot.resultnscore("ens.LOCATE.trans.results.tab")-> LOCATE.trans.other
as.data.frame(LOCATE.trans.other) -> LOCATE.trans.other


# Secreted full list 
rbind(LOCATE.secr.ens, LOCATE.secr.ref, LOCATE.secr.other) -> LOCATE.secr
LOCATE.secr %>% group_by(Protein_Name) %>% distinct() -> LOCATE.secr
colnames(LOCATE.secr)[2] <- "LOCATE_Score"

rbind(LOCATE.trans.ens, LOCATE.trans.ref, LOCATE.trans.other) -> LOCATE.trans
LOCATE.trans %>% group_by(Protein_Name) %>% distinct() -> LOCATE.trans
colnames(LOCATE.trans)[2] <- "LOCATE_Score"

#-----------------------------------------------------#
# 7) LocDB
# Results were downloaded and changed to tsv format via instructions
# only Uniprot accesion numbers given so list uplaoded to uniprot to obtain results
LocDB.fulldata <- read.csv("rostlab.tsv", header = TRUE, sep = "\t")
# clean up organism and columns
LocDB.fulldata %>% filter(grepl('Human', Organism)) -> LocDB.fulldata
LocDB.fulldata[, -which(names(LocDB.fulldata) %in% c("Organism", "O75276_HUMAN", "PKD1", "apical.plasma.membrane"))] -> LocDB.fulldata
# transmembrane terms only
LocDB.fulldata %>% filter(!grepl('apical| plasma membrane', LocalizationHomo.sapiens..Human.)) -> LocDB.trans
as.data.frame(LocDB.trans$Uniprot.KB.ID) -> LocDB.trans
write.table(LocDB.trans, "LocDB.trans.tsv", quote = FALSE, sep = "\t", col.names = NA)


# Use uniprot-function -- Must convert UniprotKB AC/ID to UniprotKB ID
uniprot.resultnscore("LocDB.trans.results.tab")-> LocDB.trans
as.data.frame(LocDB.trans) -> LocDB.trans



#-----------------------------------------------------#
# 8) Gene Ontology
# Results downloaded via Ensembl website, more details on how results were downloaded in notes
# Terms for membrane proteins were found here ----> http://geneontology.org/page/membrane-proteins, they were then limited to homo sapiens and plasma membrane in query 

GOterms.list <- function(GOfilename, protein.column){
  read.csv(GOfilename, header = FALSE, sep = "\t") -> GO.data
  colnames(GO.data)[protein.column] <- c("Protein_Name")
  data.frame(GO.data$Protein_Name) -> GO.data 
  
  return(list(GO.data))
}

# Extracellular Region Part
GOterms.list("GO.extracellspace.txt", 2) -> GO.extracellspace
as.data.frame(GO.extracellspace) -> GO.extracellspace

# Extracellular Space
GOterms.list("GO.extracellregion.txt", 2) -> GO.extracellregion
as.data.frame(GO.extracellregion) -> GO.extracellregion


# Intrinsic Component of Plasma Membrane
GOterms.list("GOterms1.txt", 14) -> GO.intrinsic
as.data.frame(GO.intrinsic) -> GO.intrinsic
# Extrinsic Component outside limited to - Plasma membrane
GOterms.list("GOterms2.txt", 14) -> GO.extrinsic
as.data.frame(GO.extrinsic) -> GO.extrinsic
# Anchored component of Plasma Membrane
GOterms.list("GOterms3.txt", 12) -> GO.anchored
as.data.frame(GO.anchored) -> GO.anchored


# Combine lists
rbind(GO.intrinsic, GO.extrinsic, GO.anchored) -> GO.trans
GO.trans %>% distinct() -> GO.trans
colnames(GO.trans)[1] <- "Protein_Name"
GO.trans %>% mutate(GO.Score = 1) -> GO.trans

rbind(GO.extracellregion, GO.extracellspace) -> GO.secr
GO.secr %>% distinct() -> GO.secr
GO.secr %>% mutate(GO.score = 1) -> GO.secr
colnames(GO.secr)[1] <- "Protein_Name"


#-----------------------------------------------------#
# 9) Uniprot 
# Results were downloaded via instructions and read into here:
UniprotKB.fulldata <- read.delim("Uniprot.Full.tab", header = TRUE, sep = "\t")
UniprotKB.fulldata[, -which(names(UniprotKB.fulldata) %in% c("Entry", "Status", "Protein.names", "Length"))] -> UniprotKB.fulldata

UniprotKB_scoren.list <- function(sub.locterms){
  
  UniprotKB.fulldata %>% filter(grepl(sub.locterms, Subcellular.location..CC.)) -> uniprotnewlist
  uniprotnewlist %>% transform(!grepl(sub.locterms, Subcellular.location..CC.)) -> uniprotnewlist
  
  # Several gene names listed in "Gene.names", first seperate by " " then by "/"
  # Isolate gene name, Delete duplicates, score
  uniprotnewlist %>% mutate(Gene.names = strsplit(as.character(Gene.names), " ")) %>% unnest(Gene.names) -> uniprotnewlist 
  uniprotnewlist %>% mutate(Gene.names = strsplit(as.character(Gene.names), "/")) %>% unnest(Gene.names) -> uniprotnewlist
  uniprotnewlist[, -which(names(uniprotnewlist) %in% c("Entry.name", "Organism", "Subcellular.location..CC."))] -> uniprotnewlist
  
  unique(uniprotnewlist) -> uniprotnewlist

  
  return(list(uniprotnewlist))
  
}

UniprotKB.secr <- UniprotKB_scoren.list("Secreted")
UniprotKB.secr <- as.data.frame(UniprotKB.secr)
UniprotKB.secr %>% mutate(uniprot.score = 1) -> UniprotKB.secr
colnames(UniprotKB.secr)[1] <- "Protein_Name"



UniprotKB.trans <- UniprotKB_scoren.list("plasma membrane|cell surface|cell membrane")
UniprotKB.trans <- as.data.frame(UniprotKB.trans)
UniprotKB.trans %>% mutate(uniprot.score = 1) -> UniprotKB.trans
colnames(UniprotKB.trans)[1] <- "Protein_Name"


######################################
#### FINAL STEP TO COMBINE LISTS ####
# Combine into two lists and get normalized score for each protein
library(plyr)
final.lists <- function(my.data.frames){
  merged_df <- join_all(my.data.frames, by = "Protein_Name", type = 'full')
  
  return(merged_df)
}


final.lists(list(organelleDB.trans, compartments_trans, proteinatlas.trans, CSPA.list, LifeDB.trans, LOCATE.trans, LocDB.trans, GO.trans, UniprotKB.trans)) -> trans.list.total
as.data.frame(trans.list.total) -> trans.list.total

final.lists(list(compartments_secr, proteinatlas.secr, LOCATE.secr, GO.secr, UniprotKB.secr)) -> secr.list.total
as.data.frame(secr.list.total) -> secr.list.total

score.final.list <- function(total.list){
  total.list[is.na(total.list)] <- 0
  total.list <- transform(total.list, Proteinatlas.nScore = (total.list$Proteinatlas.Score - min(total.list$Proteinatlas.Score))/ max(total.list$Proteinatlas.Score) - min(total.list$Proteinatlas.Score))
  total.list <- transform(total.list, Compartments.nScore = (total.list$compartments.Score - min(total.list$compartments.Score))/ max(total.list$compartments.Score) - min(total.list$compartments.Score))
  
  total.list[ , -which(names(total.list) %in% c("Proteinatlas.Score", "compartments.Score"))] -> total.list
  
  total.list %>% mutate(SCORE = rowMeans(.[,2:ncol(total.list)])) -> total.list
  


  return(total.list)
}
  
score.final.list(trans.list.total) -> trans.list.total
as.data.frame(trans.list.total) -> trans.list.total
write.table(trans.list.total, "trans.list.total.tsv", quote = FALSE, sep = '\t')


score.final.list(secr.list.total) -> secr.list.total
as.data.frame(secr.list.total) -> secr.list.total
write.table(secr.list.total, "secr.list.total.tsv", quote = FALSE, sep = '\t')




################################


###### "Gold Standard List" -- From PDB

# List was made for 3 localizations
### Funtion used on 6 and 7 used here ###
# Changes from PDB -> UnprotKB
# 1. Secreted List from term Extracellular Part
uniprot.resultnscore("Goldstd.extracellular.tab")-> Goldstd.secr
as.data.frame(Goldstd.secr) -> Goldstd.secr
write.table(Goldstd.secr, "goldstd.secr.tsv", quote = FALSE, sep = '\t')



# 2. Transmembrane List from term Membrane Part
uniprot.resultnscore("Goldstd.transmembrane.tab")-> Goldstd.trans
as.data.frame(Goldstd.trans) -> Goldstd.trans
write.table(Goldstd.trans, "goldstd.trans.tsv", quote = FALSE, sep = '\t')


# 3. Cytoplasm List from term Cytoplasmic Part
uniprot.resultnscore("Goldstd.cytoplasm.tab")-> Goldstd.cyto
as.data.frame(Goldstd.cyto) -> Goldstd.cyto
write.table(Goldstd.cyto, "goldstd.cyto.tsv", quote = FALSE, sep = '\t')
