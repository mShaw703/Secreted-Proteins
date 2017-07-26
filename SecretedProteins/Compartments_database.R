####################################
#Purpose: To sort the Extracellular data from Compartments Database
#Author: Maggie
#Date: 7/17/2017
####################################

#Call libraries
library(ggplot2)
library(markdown)

#Download data from Compartments Database
compartmentsdatabaseHU <- read.table("human_compartment_knowledge_full.tsv", sep = "\t", header = FALSE)

#Re-name colulmns with appropriate description from database
#http://compartments.jensenlab.org/Search -- used to find column names 
colnames(compartmentsdatabaseHU) = c("Identifyer", "Protein Name", "Gene Ontology #", "Subcellular Location", "Database","GO Evidence Code", "Confidence Level")

# Extract only 1st 4 columns as their own data frame 
# leaves out unusable data
location_data = as.data.frame(compartmentsdatabaseHU[,c(1,2,3,4)])

# extracts all data with "Extrcellular" as key word - main subset, will be combined with others
extracellular_subset <- location_data[grep("Extracellular", location_data$`Subcellular Location`), ]

# possibility of looking for data with ER, golgi apparatus, and vesicles due to information given on sercreted proteins on this website
# http://www.proteinatlas.org/humancell/secreted+proteins gives info. about secretory pathway, location could also indicate a secreted protein
golgi_subset <- location_data[grep("Golgi", location_data$`Subcellular Location`), ]
# vesicle_subset <- location_data[grep("vesicle", location_data$`Subcellular Location`), ] -- to broad a term, should be covered in other subsets
secretory_subset <- location_data[grep("Secretory", location_data$`Subcellular Location`), ]
# ER_subset <- location_data[grep("ER", location_data$`Subcellular Location`), ] -- to broad changed to narrow down subset
ER_subset <- location_data[grep("ER to Golgi", location_data$`Subcellular Location`), ]

# combine subsets to get all possible secreted proteins
merged_secreted <- rbind(ER_subset, extracellular_subset, golgi_subset, secretory_subset)

# should remove everything thats duplicated in Identifyer, doesnt take into account which GO# or subcellular should be saved for each protein
secreted_proteins <- merged_secreted[!duplicated(merged_secreted$Identifyer), ]

## total_numb_proteins <- location_data[!duplicated(location_data$Identifyer), ] -- just to get a sense of how many proteins out of the total are 
## secreted. Secreted_proteins returns 5,741 objects while total_numb_proteins returns 17,518 proteins (about 32.77%)





