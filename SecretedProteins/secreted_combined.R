#######################
# Purpose: to combine the possible secreted proteins from Protein Atlas and Compartments to see which subsets may overlap
# Authour: Maggie Shaw
# Date: 8/25/2017
#######################

# First have to make it so they both have the same number of columns with the same names so one data set can be formed
names(final_validated_proteins) [names(final_validated_proteins) == 'Gene'] <- 'Identifyer'
names(secreted_proteins) [names(secreted_proteins) == 'Protein Name'] <- 'Gene name'
secreted_proteins <- secreted_proteins[c(1,2,4,3)]
names(final_validated_proteins) [names(final_validated_proteins) == 'Validated'] <- 'Subcellular Location'
names(final_validated_proteins) [names(final_validated_proteins) == 'GO id'] <- 'Gene Ontology #'

# Add additional column to each dataframe stating what database its from, this way can add more data from other databases in the future
secreted_proteins["Database"] <- "Compartments"
final_validated_proteins["Database"] <- "Protein Atlas"

# Now all the columns are the same can combine into one data frame
ALL_secreted <- rbind(secreted_proteins, final_validated_proteins)
