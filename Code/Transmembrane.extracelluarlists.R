############################
#Purpose: Compile lists of Secreted and Transmembrane Proteins Pt.2
#Author: Maggie Shaw
#Date: 11/03/2017
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
subcellular_location <- read.table("subcellular_location.tsv", header = TRUE, sep = "\t")
# Validated locations only
subcellular_location %>% select(-c(Supported, Approved, Uncertain, Cell.cycle.dependency, Single.cell.variation.intensity, Single.cell.variation.spatial)) -> validated_subcellular
validated_subcellular %>% filter(Reliability == "Validated")

# terms from protein atlas for extracellular/transmembrane
validated_subcellular %>% group_by(Validated) %>% tally() -> atlas_terms
# Extracellular
validated_subcellular %>% filter(grepl('Cell Junctions| Vesicles', Validated)) -> atlas_extracellular
# Transmembrane 
validated_subcellular %>% filter(grepl('Plasma membrane', Validated)) -> atlas_transmembrane

write.csv(atlas_extracellular, "atlas_extra.csv")
write.csv(atlas_transmembrane, "atlas_trans.csv")


####################
# Compartments Database
####################
human_compartment_knowledge_full <- read.table(file = "human_compartment_knowledge_full.tsv", header = FALSE, sep = "\t")
human_compartment_knowledge_full %>% select(-c(5,6)) -> compartmentsdb
colnames(compartmentsdb) = c("Identifyer", "Protein Name", "Gene Ontology #", "Subcellular Location", "Confidence Level")
# take out all items with low confidence scores, was using 4/5 changed to 5 to narrow down results
compartments_high_conf <- compartmentsdb %>% filter(`Confidence Level` >= 5)
# find terms 
compartments_high_conf %>% group_by(`Subcellular Location`) %>% tally() -> compartments_terms


# Extracellular
compartments_high_conf %>% filter(grepl('Extracellular', `Subcellular Location`)) -> compartments_extracellular
compartments_extracellular[!duplicated(compartments_extracellular$Identifyer), ] -> comp_extracellular
# Transmembrane 
compartments_high_conf %>% filter(grepl('Transmembrane|Receptor complex', `Subcellular Location`)) -> compartments_transmembrane
compartments_transmembrane[!duplicated(compartments_transmembrane$Identifyer), ] -> comp_transmembrane

write_csv(comp_extracellular, "comp_extracellular.csv")
write_csv(comp_transmembrane, "comp_transmembrane.csv")

################
#MetazsecKB
################

# Metaz gives highly likely secreted data, just need to remove duplicates
metaz_FULL <- read.table(file = "funseckb2_search_results.txt", header = FALSE, sep = "\t")
metaz_FULL %>% select(-c(V2)) -> metaz_FULL2
metaz_final_secreted <- metaz_FULL2[!duplicated(metaz_FULL2$V4), ] 

write_csv(metaz_final_secreted, "metaz_secreted.csv")


####################
# Combining Lists from Protein Atlas and Compartments
####################
# Changing column names to match and addidng a column name with the database
atlas_extracellular %>% select(-c(Reliability)) %>% rename(Identifyer = Gene, Name = Gene.name, Subcellular.Location = Validated) %>% mutate(Database = "Protein Atlas")-> atlas.extra
atlas_transmembrane %>% select(-c(Reliability)) %>% rename(Identifyer = Gene, Name = Gene.name, Subcellular.Location = Validated) %>% mutate(Database = "Protein Atlas")-> atlas.trans
comp_extracellular %>% select (-c(`Confidence Level`)) %>% rename(Name = `Protein Name`, GO.id = `Gene Ontology #`, Subcellular.Location = `Subcellular Location`) %>% mutate (Database = "Compartments") -> comp.extra
comp_transmembrane %>% select (-c(`Confidence Level`)) %>% rename(Name = `Protein Name`, GO.id = `Gene Ontology #`, Subcellular.Location = `Subcellular Location`) %>% mutate (Database = "Compartments") -> comp.trans
comp.extra %>% c("Identifyer", "Name", "Subcellular.Location", "GO.id", "Database")
comp.trans %>% c("Identifyer", "Name", "Subcellular.Location", "GO.id", "Database")


rbind(atlas.extra, comp.extra) -> extracellular.total 
rbind(atlas.trans, comp.trans) -> transmembrane.total

write_csv(extracellular.total, "extracellular_total.csv")
write_csv(transmembrane.total, "transmembrane_total.csv")







