# Transmembrane/ Secreted Protein Lists 
___
## Step 1: Create 2 lists; Each contains list of proteins and if its present in the database
### Databases:
#### 1. Organelle DB [http://labs.mcdb.lsa.umich.edu/organelledb/search.php]
From this link was able to limit search to membrane protein > "Plasma Membrane", Organism > "human", and "Download in Flat File". Used >wget< and link to flat file in Terminal to get results in a tabl delim. file that was saved with a .txt extension. Beacuse the results were already organised by location and organism during downlaod, only had to limit results to the Standard name and add a database score of 1 to all entries because no confidence score was given[1].

<br>

#### 2. Compartments [https://compartments.jensenlab.org/Downloads]
Includes 4 channels of data[2] where transmembrane and secreted proteins can be found. Downloaded directly in code where columns containing the localization, protein name, and confidence score were parsed. Transmembrane proteins were pulled by "Plasma membrane|cell surface" while secreted proteins were pulled by "Extracellular". Duplicate entries were removed and final confidence scores for duplicated proteins reflect the average score for all the entries of that protein. Lists were finalized by removing the localization column.

<br> 

#### 3. Protein Atlas [https://www.proteinatlas.org/about/download] -> select "3 Subcellular Location Data"
Downloaded from database. Columns containing the Gene name, reliability, and GO localization were parsed. Transmembrane proteins were pulled by "Plasma membrane" while secreted proteins were pulled by "Cell Junctions|Vesicles". Reliability scores[3] were converted to numbers 1 - 4, to compare to other sources.

<br>

#### 4. Cell Surface Protein Atlas [http://wlab.ethz.ch/cspa/#downloads] -> select "CSPA Validated Surfaceome Proteins"
Download from database, gives only transmembrane list results. Had to use **openxlsx** package to read through exel spreadsheet file. All columns parsed except the Entrez gene symbol column and protein probability score columns. 

<br>


#### 5. LifeDB [http://www.dkfz.de/en/mga/Groups/LIFEdb-Database.html]
Data was downloaded via: (**Pichai info. here**). Only "Plasma membrane" could be used to search for potential transmembrane proteins. 

<br>

#### 6. LOCATE
Data downloaded via instructions(**Pichai info. here**). Protein names aren’t given in the data so accession numbers had to be loaded into Uniprot[4] and the Uniprot results were downloaded as the results from LOCATE. Ensemble ID’s, Entrez Gene ID’s, ref-seq ID’s, and one other group of accession numbers was parsed from the LOCATE data file and uploaded to the Uniprot search in separate groups. Results containing only the protein name results were put back into data frame format in R and duplicate entries removed to create secreted and transmembrane lists. 

<br>

#### 7. LocDB
Data downloaded via instructions(). Data included other organisms so “human” entries had to be parsed. Uniprot accession numbers pulled and uploaded to Uniprot search [4]. Results containing only the protein name results were put back into data frame format in R and duplicate entries removed to create secreted and transmembrane lists. LocDB contained no terms for secreted proteins.

<br>

#### 8. Gene Ontology
**Terms for secreted proteins and transmembrane proteins downloaded via different methods.** GO terms used for the secreted list are Extracellular Space (GO:0005165) and Extracellular Region (GO:0005576). To download results eneter GO # into the "Search GO data" search bar on [http://www.geneontology.org/]. Select the "Link to all genes and gene products" option on the next page and limit the results from the link to **Homo sapiens**. Download the results via the command line (wget) and save as a ".txt" file. 
<br> 
Terms for transmembrane proteins were found here [http://geneontology.org/page/membrane-proteins] and limited to Intrinsic Component of Plasma Membrane, Extrinsic Component outside of the plasma membrane, and Anchored component of Plasma Membrane. GO results were downloaded, while making sure a column containing the "Gene/Product (bioentity_label)" is included in the download. Download the results via the command line (wget) and save as a ".txt" file. 
<br>
Once downloaded secreted and transmembrane lists were created by combining the data from the "Gene/Product (bioentity_label)" column in each .txt file. Duplicates were removed and each entry was given a score of 1. 

#### 9. UniprotKB - Swiss-prot
Data from Uniprot was downloaded from here -> [] and the option for "Reveiwed - Swiss-Prot" on the left side tool bar was selected. Before downloading it is important to select the pencil icon on the right side of the table. This leads to a "Customize results table" page, select "Subcellular Location (CC) under the Subcellular Location tab to add a location column when downloading the data. Download proteins in a ".tab" file format. 


#### GOLD STANDARD -- Protein Data Bank (PDB)

#### List of files needed before running 







