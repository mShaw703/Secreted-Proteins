# Transmembrane/ Secreted Protein Lists 
___
## Step 1: Create 2 lists; Each contains list of proteins and if it's present in the database
### Databases:
#### 1. Organelle DB [http://labs.mcdb.lsa.umich.edu/organelledb/search.php]
From this link was able to limit search to membrane protein > "Plasma Membrane", Organism > "human", and "Download in Flat File". Used `wget` and link to flat file in Terminal to get results in a tab deliminated file that was saved with a `.txt` extension. Beacuse the results were already organized by location and organism during download, only had to limit results to the hgnc_symbol and add a database score of "1"

<br>

#### 2. Compartments [https://compartments.jensenlab.org/Downloads]
Includes 4 channels of data where transmembrane and secreted proteins can be found. Downloaded directly in code where columns containing the ensembl peptide id, localization, protein name, and confidence score were parsed. Transmembrane proteins were pulled by "Plasma membrane|cell surface" while secreted proteins were pulled by "Extracellular". Duplicate entries were removed and final confidence scores for duplicated proteins reflect the average score for all the entries of that protein. Proteins with confidence scores were saved in seperate file for potential use following analysis. Ensembl IDs were parsed into their own (2) single columned list and a biomaRt query was used to pull the hgnc_symbol. A score of "1" was given to all resulting hgnc_symbols.
<br>
**IMPORTANT NOTE: Compartments uses 4 channels of data to find subcellular localization information.** <br>
1. **Knowledge Channel** - Based on annotations from UniprotKB <br>
2. **Experiments Channel** - Based on data obtained by Protein Atlas through experimentation<br>
3. **Text Mining Channel** - Based on text mining of abstracts on Medline <br>
4. **Predictions Channel** - Used computational prediction methods (WoLF PSORT and YLoc) to determine subcellular localization


#### 3. Cell Surface Protein Atlas [http://wlab.ethz.ch/cspa/#downloads] -> select "CSPA Validated Surfaceome Proteins"
Download from database, gives only transmembrane list results. Had to use **openxlsx** package to read through exel spreadsheet file. All columns parsed except the Entrez gene symbol column and protein probability score columns were saved to their own file for potential use following analysis. Entrez gene symbols were put into their own single columned list and a biomaRt query was used to pull the hgnc_symbol. A score of "1" was given to all resulting hgnc_symbols.


<br>

#### 4. LOCATE [http://locate.imb.uq.edu.au/]
Data downloaded via instructions(**Pichai info. here**). Protein names aren’t given in the data so accession numbers had to be loaded into Uniprot[4] and the Uniprot results were downloaded as the results from LOCATE. Ensemble ID’s, Entrez Gene ID’s, and ref-seq ID’s were parsed from the LOCATE data file and put into their own single columned data frames. BiomaRt queries were run on each list to pull the hgnc_symbol. A score of "1" was given to all resulting hgnc_symbols, lists were combined into complete secreted and transmembrane lists.

<br>

#### 5. LocDB [https://www.rostlab.org/services/locDB/]
Data downloaded via instructions(**Pichai info. here**). Data included other organisms so “human” entries had to be parsed. Uniprot accession numbers pulled  into a single columned dataframe and a biomaRt query was used to pull the hgnc_symbol. A score of "1" was given to all resulting hgnc_symbols. LocDB contained no terms for secreted proteins.

<br>

#### 6. Gene Ontology [http://www.geneontology.org/]
**Terms for secreted proteins and transmembrane proteins downloaded via different methods.** GO terms used for the secreted list are Extracellular Space (GO:0005165) and Extracellular Region (GO:0005576). To download results eneter GO # into the "Search GO data" search bar on the Gene Ontology main page. Select the "Link to all genes and gene products" option on the next page and limit the results from the link to **Homo sapiens**. Download the results via the command line (wget) and save as a ".txt" file. 

<br> 

  Terms for transmembrane proteins were found here [http://geneontology.org/page/membrane-proteins] and limited to Intrinsic Component of Plasma Membrane, Extrinsic Component outside of the plasma membrane, and Anchored component of Plasma Membrane. GO results were downloaded, while making sure a column containing the "Gene/Product (bioentity_label)" is included in the download. Download the results via the command line (wget) and save as a ".txt" file. 
  
<br>

  Once downloaded secreted and transmembrane lists were created by combining the data from the "UniprotID" column in each .txt file. BiomaRt queries were run on each list to pull the hgnc_symbol. A score of "1" was given to all resulting hgnc_symbols to complete the secreted and transmembrane lists.

#### 7. UniprotKB - Swiss-prot [http://www.uniprot.org/uniprot/]
Homo sapien data from UniprotKB was selected and the option for "Reveiwed - Swiss-Prot" on the left side tool bar was selected to choose only manually reviewed entries. Before downloading it is important to select the pencil icon on the right side of the table. The pencil icon leads to a "Customize results table" page, where "Subcellular Location (CC)" under the **Subcellular Location** tab is selected, adding a protein localization column when downloading the data. Download proteins in a ".tab" file format. 

<br>
  
  Once downloaded, the term "Secreted" was used to pull "uniportswissprot" protein names for the secreted list and "plasma membrane|cell surface|cell membrane" were used to pull "uniportswissprot" protein names for transmembrane proteins. BiomaRt queries were run on each list to pull the hgnc_symbols for protein coding genes and a score of "1" was given to all resulting hgnc_symbols to complete the secreted and transmembrane lists.
 

### Gold Standard & Negative Control -- Protein Atlas [https://www.proteinatlas.org/about/download] -> select "3 Subcellular Location Data"
Downloaded from database. Columns containing the Gene name, reliability, and GO localization were parsed. For gold standard for Transmembrane proteins the term "Plasma membrane" was used, while secreted proteins were pulled by "Cell Junctions|Vesicles". For the negative control lists for secreted and transmembrane, pulled all proteins that were not listed as being those terms. Reliability scores were converted to numbers 1 - 4, to potentially compare to other sources with given confidence scores and saved to a file. Dataframes containing only Esnsembl IDs were used to run a biomaRt query to get only the hgnc_symbol for each gene. Finally all hgnc_symbols were given a score of '1' (for negative control lists as well).

**IMPORTANT NOTE** Reliability scores on Protein Atlas are given as terms and were converted into numbers 1 - 4 to compare to other sources.  <br>
1.*"**Uncertain** - If the antibody-staining pattern contradicts experimental data or no expression is detected on the RNA level."*<br>
2.*"**Approved** - If the localization of the protein has not been previously described and was detected by only one antibody without additional antibody validation."* <br>
3.*"**Supported** - There is no enhanced validation of the used antibody, but the annotated localization is reported in literature"*. <br>
4.*"**Enhanced** - One or more antibodies are enhanced validated and there is no contradicting data, for example literature describes experimental evidence for a different location."* 
___

## Step 2: Combine the Lists
Lists were combined by common hgnc_symbols. and combined with their corresponding "gold standard" list and "negative control" list. A column was also created stating if "yes" the protein was found in the gold standard, or "no" it wasn't. These raw score tables can be found in `secr.list.scores2.tsv` and `trans.list.scores2.tsv`.

___

Bioconductor and BiomaRt Information -> [https://bioconductor.org/packages/release/bioc/html/biomaRt.html]



#### List of files needed before running `SecTMLists.Rmd`
1. Search results from OrganelleDB search, one file with `.txt` extension <br>
`OrganelleDBresults.txt` in code

2. File from Cell Surface Protein Atlas, one file with .xlsx extension <br>
`S2_File.xlsx` in code

3. File from LOCATE, one file with `.tsv` extension<br>
`LOCATE_human_v6_20081121.tsv` in code

4. File from LocDB, one file with `.tsv ` extension<br>
`rostlab.tsv` in code

5. Search results from Gene Ontology search, 5 files with `.txt` extension<br>
`GO.extracellspace.txt`, `GO.extracellregion.txt`, `GOterms1.txt`, `GOterms2.txt`, `GOterms3.txt` in code

6. File from Uniprot-Swissprot, 1 file with `.tab` extension<br>
`Uniprot.Full.tab` in code

7. File from Protein Atlas, 1 file with `.tsv` extension<br>
`subcellular_location.tsv` in code

___

## Step 3: Analysis of "Secreted" and "Transmembrane" Lists `SecTmstats.Rmd`

Only need the final files with raw scores from the List creation and combining program.
* `translistscores2.tsv` <br>
* `secrlistscores2.tsv`<br>

First created a paried bar plot using `ggplot`. Shows the number of proteins from each source in each list. 

Created an upset plot using the R package `UpsetR`. Upset plots are an alternative to a Venn Diagram and are used to compare more than three sources. 
* Upset plots -> [http://caleydo.org/tools/upset/]
* UpsetR package -> [https://cran.r-project.org/web/packages/UpSetR/README.html]

Following analysis, final lists were created by summing the scores for each protein (including gold standard, excluding negative control) and selecting the proteins that were in at least half of the sources. Final lists consist of hgnc_symbol and the "summed score" . for those proteins. 

Knitted analysis can be found here -> [Stats](https://github.com/mShaw703/Transmembrane-Secreted-Proteins/blob/master/Code/SecTMstats.pdf)







