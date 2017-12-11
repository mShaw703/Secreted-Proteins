############################
#Purpose: Compile lists of Secreted and Transmembrane Proteins Pt.2
#Author: Maggie Shaw
#Date: 11/03/2017
#Edit data: 12/06/2017
###########################

###########
# Libraries
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(DataCombine)
###########


################
# Protein Atlas
################

# Upload file / manipulate columns to work with for transmembrane/ extracellular
subcellular_location <- read.table("subcellular_location.tsv", header = TRUE, sep = "\t")
# Validated/Supported locations only
subcellular_location %>% select(-c(Approved, Uncertain, Cell.cycle.dependency, Single.cell.variation.intensity, Single.cell.variation.spatial)) -> subcellular_location
# Give reliability a number score from 1 - 4 (1 being the worst, 4 the best)
subcellular_location %>% mutate(Reliability = recode(Reliability, "Uncertain" = "1", "Approved" = "2", "Supported" = "3", "Validated" = "4")) -> subcellular_location2
subcellular_location2[, "Reliability"] <- as.numeric(subcellular_location2[, "Reliability"])
# Combine Validated and Supported column to one GO_type column
subcellular_location2 <- unite(subcellular_location2, GO_Type, c(Validated, Supported), sep = "")
# Rename columns to match compartments 
colnames(subcellular_location2) = c('ensembl_peptide_id', 'hgnc_symbol', 'Score', 'GO_Type', 'GO')
subcellularlocation_list <- split(subcellular_location2, f=subcellular_location2[,"hgnc_symbol"])

#########################
#Function to get a max score for each list from protein atlas, extracellular

getrealEX.a <- function(x)
{
  # get max num
  tmpX.a <- x[x[,"Score"]==max(x[,"Score"]),]
  tmpX.a <- tmpX.a[grep('Cell Junctions|Vesicles', tmpX.a[,"GO_Type"], value=F),]
  return(tmpX.a);
}

outputEXList.a <- do.call("rbind", lapply(subcellularlocation_list, FUN=getrealEX.a));
subcellular_extracellular <- unique(outputEXList.a[,c("hgnc_symbol", "Score")]) 

#Remove duplicates
subcellular_extracellular <- subcellular_extracellular[order(-subcellular_extracellular[,2]),];
subcellular_extracellular <- subcellular_extracellular[!duplicated(subcellular_extracellular[,1]),];

#Now make sure score is at least a 3
subcellular_extracellular <- subcellular_extracellular[subcellular_extracellular[,2]>=3,];
subcellular_extracellular <- subcellular_extracellular[-2];
# subcellular_extracellular <- unique(subcellular_extracellular[,1]);

# add database column for merge later
subcellular_extracellular %>% mutate(Database = "Protein Atlas") -> atlas_extracellular

#########################
# Function to get max score from each list from protein atlas, Transmembrane

getrealTM.a <- function(x)
{
  # get max num
  tmpX.b <- x[x[,"Score"]==max(x[,"Score"]),]
  tmpX.b <- tmpX.b[grep('Plasma membrane', tmpX.b[,"GO_Type"], value=F),]
  return(tmpX.b);
}

outputTMList.a <- do.call("rbind", lapply(subcellularlocation_list, FUN=getrealTM.a));
subcellular_transmembrane <- unique(outputTMList.a[,c("hgnc_symbol", "Score")])
#Remove one known non-membrane protein in list
subcellular_transmembrane <- subcellular_transmembrane[subcellular_transmembrane[,"hgnc_symbol"]!="DNAJC9",]

#Remove duplicates
subcellular_transmembrane <- subcellular_transmembrane[order(-subcellular_transmembrane[,2]),];
subcellular_transmembrane <- subcellular_transmembrane[!duplicated(subcellular_transmembrane[,1]),];

#Now make sure score is at least a 3
subcellular_transmembrane <- subcellular_transmembrane[subcellular_transmembrane[,2]>=3,];
subcellular_transmembrane <- subcellular_transmembrane[-2];


# Add column for merge later
subcellular_transmembrane %>% mutate(Database = "Protein Atlas") -> atlas_transmembrane




####################
# Compartments Database
####################

# Upload file / manipulate columns to work with for transmembrane/ extracellular
compartmentsdb <- read.table(file = "human_compartment_knowledge_full.tsv", header = FALSE, sep = "\t")
# re- named columns 
colnames(compartmentsdb) = c("ensembl_peptide_id", "hgnc_symbol", "GO", "GO_Type", "Source", "Evidence_Code", "Score")
compartmentdb_list <- split(compartmentsdb, f=compartmentsdb[,"hgnc_symbol"])

#########################
# Function to get a max score for each list from Compartments, Transmembrane

getrealTM.b <- function(x)
{
  # get max num
  tmpX.c <- x[x[,"Score"]==max(x[,"Score"]),]
  tmpX.c <- tmpX.c[grep("Plasma membrane|Cell surface", tmpX.c[,"GO_Type"], value=F),]
  return(tmpX.c);
}

outputTMList.b <- do.call("rbind", lapply(compartmentdb_list, FUN=getrealTM.b));
compartmentsdb_transmembrane <- unique(outputTMList.b[,c("hgnc_symbol", "Score")])
#Remove one known non-membrane protein in list
compartmentsdb_transmembrane <- compartmentsdb_transmembrane[compartmentsdb_transmembrane[,"hgnc_symbol"]!="DNAJC9",]


#Remove duplicates
compartmentsdb_transmembrane <- compartmentsdb_transmembrane[order(-compartmentsdb_transmembrane[,2]),];
compartmentsdb_transmembrane <- compartmentsdb_transmembrane[!duplicated(compartmentsdb_transmembrane[,1]),];

#Now make sure score is at least a 3
compartmentsdb_transmembrane <- compartmentsdb_transmembrane[compartmentsdb_transmembrane[,2]>=3,];
compartmentsdb_transmembrane <- compartmentsdb_transmembrane[-2];
#compartmentsdb_transmembrane <- unique(compartmentsdb_transmembrane[,1]);

#Add column for merge later
compartmentsdb_transmembrane %>% mutate(Database = "Compartments") -> compartments_trans


############################
#Function to get a max score for each list from Compartments, Transmembrane

getrealEX.b <- function(x)
{
  # get max num
  tmpX.d <- x[x[,"Score"]==max(x[,"Score"]),]
  tmpX.d <- tmpX.d[grep("Extracellular", tmpX.d[,"GO_Type"], value=F),]
  return(tmpX.d);
}

outputEXList.b <- do.call("rbind", lapply(compartmentdb_list, FUN=getrealEX.b));
compartmentsdb_extracellular <- unique(outputEXList.b[,c("hgnc_symbol", "Score")])

#Remove duplicates
compartmentsdb_extracellular <- compartmentsdb_extracellular[order(-compartmentsdb_extracellular[,2]),];
compartmentsdb_extracellular <- compartmentsdb_extracellular[!duplicated(compartmentsdb_extracellular[,1]),];

#Now make sure score is at least a 3
compartmentsdb_extracellular <- compartmentsdb_extracellular[compartmentsdb_extracellular[,2]>=3,];
compartmentsdb_extracellular <- compartmentsdb_extracellular[-2];
#compartmentsdb_transmembrane <- unique(compartmentsdb_transmembrane[,1]);

#Add column for merge later
compartmentsdb_extracellular %>% mutate(Database = "Compartments") -> compartments_extra


########################
#MetazsecKB
########################

# Metaz gives highly likely secreted data, just need to remove duplicates
metaz_FULL <- read.table(file = "funseckb2_search_results.txt", header = FALSE, sep = "\t")
metaz_FULL %>% select(-c(V2)) -> metaz_FULL2
metaz_final_secreted <- metaz_FULL2[!duplicated(metaz_FULL2$V4), ] 

write_csv(metaz_final_secreted, "metaz_secreted.csv")


####################
# Combining Lists from Protein Atlas and Compartments
####################

# list of total transmembrane and extracellular proteins
rbind(compartments_extra, atlas_extracellular) -> extracellular.total 
rbind(compartments_trans, atlas_transmembrane) -> transmembrane.total

# find dupilcates from both lists and put in list
extracellular.total[duplicated(extracellular.total$hgnc_symbol), ] -> duplicated.extra
# mutate columns for new list
duplicated.extra %>% mutate(Location = "extracellular") %>% mutate(Database = "Compartments, Protein Atlas") -> duplicated.extra
# For transmembrane: 
transmembrane.total[duplicated(transmembrane.total$hgnc_symbol), ] -> duplicated.trans
duplicated.trans %>% mutate(Location = "transmembrane") %>% mutate(Database = "Compartments, Protein Atlas") -> duplicated.trans
# merge
rbind(duplicated.extra, duplicated.trans) -> poss.proteins 



write_csv(poss.proteins, "possible_target_proteins.csv")
write_csv(extracellular.total, "extracellular_total.csv")
write_csv(transmembrane.total, "transmembrane_total.csv")







