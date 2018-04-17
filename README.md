# Transmembrane/ Secreted Protein Lists 
___
## Step 1: Create 2 lists; Each contains list of proteins and if it's present in the database
### Databases:
#### 1. Organelle DB [http://labs.mcdb.lsa.umich.edu/organelledb/search.php]
From this link was able to limit search to membrane protein > "Plasma Membrane", Organism > "human", and "Download in Flat File". Used `wget` and link to flat file in Terminal to get results in a tab deliminated file that was saved with a `.txt` extension. Beacuse the results were already organized by location and organism during download, only had to limit results to the standard protein name and add a database score of "1"[1].

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

#### 6. LOCATE [http://locate.imb.uq.edu.au/]
Data downloaded via instructions(**Pichai info. here**). Protein names aren’t given in the data so accession numbers had to be loaded into Uniprot[4] and the Uniprot results were downloaded as the results from LOCATE. Ensemble ID’s, Entrez Gene ID’s, ref-seq ID’s, and one other group of accession numbers was parsed from the LOCATE data file and uploaded to the Uniprot search in separate groups. Results containing only the protein name results were put back into data frame format in R and duplicate entries removed to create secreted and transmembrane lists. 

<br>

#### 7. LocDB [https://www.rostlab.org/services/locDB/]
Data downloaded via instructions(**Pichai info. here**). Data included other organisms so “human” entries had to be parsed. Uniprot accession numbers pulled and uploaded to Uniprot search [4]. Results containing only the protein name results were put back into data frame format in R and duplicate entries removed to create secreted and transmembrane lists. LocDB contained no terms for secreted proteins.

<br>

#### 8. Gene Ontology [http://www.geneontology.org/]
**Terms for secreted proteins and transmembrane proteins downloaded via different methods.** GO terms used for the secreted list are Extracellular Space (GO:0005165) and Extracellular Region (GO:0005576). To download results eneter GO # into the "Search GO data" search bar on the Gene Ontology main page. Select the "Link to all genes and gene products" option on the next page and limit the results from the link to **Homo sapiens**. Download the results via the command line (wget) and save as a ".txt" file. 

<br> 

  Terms for transmembrane proteins were found here [http://geneontology.org/page/membrane-proteins] and limited to Intrinsic Component of Plasma Membrane, Extrinsic Component outside of the plasma membrane, and Anchored component of Plasma Membrane. GO results were downloaded, while making sure a column containing the "Gene/Product (bioentity_label)" is included in the download. Download the results via the command line (wget) and save as a ".txt" file. 
  
<br>

  Once downloaded secreted and transmembrane lists were created by combining the data from the "Gene/Product (bioentity_label)" column in each .txt file. Duplicates were removed and each entry was given a score of 1. 

#### 9. UniprotKB - Swiss-prot [http://www.uniprot.org/uniprot/]
Homo sapien data from UniprotKB was selected and the option for "Reveiwed - Swiss-Prot" on the left side tool bar was selected to choose only manually reviewed entries. Before downloading it is important to select the pencil icon on the right side of the table. The pencil icon leads to a "Customize results table" page, where "Subcellular Location (CC)" under the **Subcellular Location** tab is selected, adding a protein localization column when downloading the data. Download proteins in a ".tab" file format. 

<br>
  
  Once downloaded, the term "Secreted" was used to pull proteins for the secreted list and "plasma membrane|cell surface|cell membrane" were used to pull transmembrane proteins. Duplicate entries were removed and each entry was given a score of 1. 

### GOLD STANDARD -- Protein Data Bank (PDB)[http://www.rcsb.org/pdb/search/advSearch.do?search=new]
Using the adavnced search interface found at the following link, select "Cell Component Browser (GO)" under the **Biology** section of the drop down tab. This opens a popup where the terms "Extracellular Part", "Plasma Membrane Part", and "Cytoplasmic Part" can be selected. 



### List of files needed before running 
1. Search results from OrganelleDB, one file with `.txt` extension <br>
`OrganelleDBresults.txt` in 

2. 

___

[1]: If no confindence score for protein localization was given by the database of origin, all entries in the list are given a score of **1**. When the protein lists are compiled "NA" values will be given a score of **0**. Once all "NA" values are given their zero score, sources with a given confidence score for subcellular loaclization will be normalized on a scale of **0 - 1** so that each source can be compared. 
<br>
[2]: Compartments uses 4 channels of data to find subcellular localization information. <br>
1. **Knowledge Channel** - Based on annotations from UniprotKB <br>
2. **Experiments Channel** - Based on data obtained by Protein Atlas through experimentation<br>
3. **Text Mining Channel** - Based on text mining of abstracts on Medline <br>
4. **Predictions Channel** - Used computational prediction methods (WoLF PSORT and YLoc) to determine subcellular localization
<br>
[3]: Reliability scores on Protein Atlas are given as terms and were converted into numbers 1 - 4 to compare to other sources.  <br>
1.*"**Uncertain** - If the antibody-staining pattern contradicts experimental data or no expression is detected on the RNA level."*<br>
2.*"**Approved** - If the localization of the protein has not been previously described and was detected by only one antibody without additional antibody validation."* <br>
3.*"**Supported** - There is no enhanced validation of the used antibody, but the annotated localization is reported in literature"*. <br>
4.*"**Enhanced** - One or more antibodies are enhanced validated and there is no contradicting data, for example literature describes experimental evidence for a different location."* 
<br>
[4]: 







