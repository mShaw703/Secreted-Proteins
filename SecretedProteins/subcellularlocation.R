## must read in the CSV file from protein atlas database as an excel spread sheet. Program should start similar to the compartments 
## database file changes from CSV to XLS and imported using R studio

##extracted all validated data and removed "junk" columns
subcellular_location_validated <- subcellular_location[grep("Validated", subcellular_location$'Reliability'),]
validated_refined <- as.data.frame(subcellular_location_validated[,c(1,2,4,11)])

## begin to seperate out terms where things seem to be secreted, using "Vesicles" and "Cell Junctions"
vesicle_subset <- validated_refined[grep("Vesicle", validated_refined$`Validated`),]
celljunctions_subset <- validated_refined[grep("Cell Junctions", validated_refined$'Validated'),]

## combine both tables and remove repeats
merged_validated_secreted <- rbind(celljunctions_subset, vesicle_subset)
final_validated_proteins <- merged_validated_secreted[!duplicated(merged_validated_secreted$'Gene'),]
