# Databases
For **Compartments**: <http://compartments.jensenlab.org/Downloads> use the knowledge channel, humans <br>
For **Protein Atlas**: <http://www.proteinatlas.org/about/download> use the Subcellular Location Data <br>
New database **MetazSecKB**: <http://bioinformatics.ysu.edu/secretomes/animal/index.php> 

## Compartments
When going through Compartments dataset, it was determined that using only the term ***"Extracellular"*** was enough to find all potentially secreted/extracellular proteins. Other terms shouldnt be needed, the terms would be duplicated in the Extracellular list. For the other list of transmembrane proteins, two terms were used ***"Plasma membrane"*** and ***"Cell Surface"*** .

<br>

## Protein Atlas
When going through data from the Protein Atlas data base, each term in the ***"Reliability"*** column was given a number score of 1 - 4 based off the definition for each reliability term given from the protein atlas database -> <http://www.proteinatlas.org/about/assays+annotation>.

Once a data frame was created that contained all the well supported locations, began filtering through terms as was done with the compartments data base, trying to follow a similar pattern. Start by filtering for ***"Cell Junctions"*** and ***"Vesicles"*** for the extracellular list and ***"Plasma Membrane"*** for the transmembrane list. 


<br>

## MetazsecKB

To get data: In the ***"Search by Subcellular Location"*** section select ***"Species: Homo sapien"*** . In the ***"Predicted Subcellular Location"*** select ***"highly likely secreted"*** and search. Should be able to download a .txt file on the next page. Because the data base only gives secreted, list can be compared to the data from the transmembrane and extracellular lists from the other databases. Unnecissary column removed containing UNIProt ID and duplicates removed to create the final list. 

<br>

# Formula to get Lists of Target Proteins (secreted and transmembrane) from Compartments and Protein Atlas

Both compartments and protein atlas contain very similar information on protein subcellular location. Given their similarities, column names could be changed to be identical for both databases, so that secretred/transmembrane proteins could be easily identified. To find highly likely secreted and transmembrane proteins a confidence score was given to each entry. Compartments gave each entry a score from 1-5, where 5 was highly likely a secreted/transmembrane protein. Protein atlas gave one of four Reliability terms to their entries that were converted to numbers 1-4, where 4 was highly likely a secreted/transmembrane protein.

A formula was used to narrow down proteins that could confidently be considered secreted/transmembrane. The HNGC name for each protein was isolated into its own list based on a score of 3 or greater for both subcellular locations in the protein atlas and compartments databases. Duplicates were also removed from each of the 4 lists; Compartments/secreted, compartemnts/transmembrane, protein atlas/secreted, protein atlas/transmembrane. Once duplicates were removed a column was added giving the database the entry was from for later use when secreted and transmembrane lists are merged.

Two datasets, a total secreted list and a total transmembrane list were formed and duplicates found. A new column was added to ther duplicated items indicating if it was a secreted or transmembrane protein. Duplicated proteins from both subcellular locations were moved to one list of possible target proteins.

<br>

***Still figuring out how to incorperate MetazsecKB into the list. The list already consist of highly likely secreted proteins. Descriptor coloumn in MetazsecKB occasionally lists the HNGC name for the protein but is not consistant in what kind of descriptor is used to describe the entry.***

***Please see Google Drive for more information : https://drive.google.com/drive/u/0/folders/1_C6CARdJBRfrCW6NnRVmTc9Bq-uZlZUY ***

