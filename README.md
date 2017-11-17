# Databases
For **Compartments**: <http://compartments.jensenlab.org/Downloads> use the knowledge channel, humans <br>
For **Protein Atlas**: <http://www.proteinatlas.org/about/download> use the Subcellular Location Data <br>
For **LOCATE**: <http://locate.imb.uq.edu.au/downloads.shtml> use the Homo sapiens Locate dataset. <br>
** Edit: LOCATE was never used as a source, data may be too out of date, last update Nov. 2008** <br>
New database **MetazSecKB**: <http://bioinformatics.ysu.edu/secretomes/animal/index.php> 

## Compartments
When going through Compartments dataset, there were several terms that may have been referring to a secreted protein. Filtered through the terms and narrowed it down to a few to compile a list of possible secreted proteins.
Terms used for compartments: 'Vesicle', 'Secretory', 'Extracellular'. 'Golgi' and 'ER' were also used but after review of the terms that came from searching the two key words; 'ER to Golgi' was determined to be the best possible search term. <br>
**Edit: Determined that using only the term ***"Extracellular"*** was enough to find all potentially secreted proteins. Other terms shouldnt be needed if secreted would have been duplicated in the Extracellular list. For the other list of transmembrane proteins only two terms were used ***"Transmembrane"*** and ***"Receptor complex"*** .** 

<br>

## Protein Atlas
When going through data from the Protein Atlas data base. Data was recieved from website as a CSV file. I extracted only the validated genes, in this case however supported may also be a good option. My reasoning was base off the definition for each score given here -> <http://www.proteinatlas.org/about/assays+annotation>. Removed several other columns in file that either did not include data or that had irrelevant data to the project. 

Once a data frame was created that contained all the well supported locations, began filtering through terms as was done with the compartments data base, trying to follow a similar pattern. Start by filtering for ***"Cell Junctions"*** and ***"Vesicles"*** for the extracellular list and ***"Plasma Membrane"*** for the transmembrane list. Only three terms used for this database. 

<br>

## MetazsecKB

To get data: In the ***"Search by Subcellular Location"*** section select ***"Species: Homo sapien"***. In the ***"Predicted Subcellular Location"*** select ***"highly likely secreted"*** and search. Should be able to download a .txt file on the next page. Because the data base only gives secreted, list can be compared to the data from the transmembrane and extracellular lists from the other databases.



#########

Now the two data sets can be compared to see if there are any duplicates between them. Also want to cross check to see if the terms used to find possible secreted proteins in Compartments is valid. 

First had to edit both sets so the column names matched. Began with "Identifyer"; it was the same for both sets giving the 'ENSG#. The second column is labeled "Gene Name" and is the same in both sets. The last two columns are "GO#" and "Location". An additional column was added stating the database used. 
