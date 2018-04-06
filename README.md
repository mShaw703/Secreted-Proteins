# Transmembrane/ Secreted Protein Lists 
___
<br>
## Step 1: Create 2 lists; Each contains list of proteins and if its present in the database
<br>
### Databases:
<br>
1. Organelle DB [http://labs.mcdb.lsa.umich.edu/organelledb/search.php]
From this link was able to limit search to membrane protein > "Plasma Membrane", Organism > "human", and "Download in Flat File". Used >wget< and link to flat file in Terminal to get results in a tabl delim. file that was saved with a .txt extension. Beacuse the results were already organised by location and organism during downlaod, only had to limit results to the Standard name and add a database score of 1 to all entries because no confidence score was given[1].
<br>
2. Compartments [https://compartments.jensenlab.org/Downloads]
Includes 4 channels of data[2] where transmembrane and secreted proteins can be found. Downloaded directly in code where columns containing the localization, protein name, and confidence score were parsed. Transmembrane proteins were pulled by "Plasma membrane|cell surface" while secreted proteins were pulled by "Extracellular". Duplicate entries were removed and final confidence scores for duplicated proteins reflect the average score for all the entries of that protein. Lists were finalized by removing the localization column.
<br> 
3. Protein Atlas [https://www.proteinatlas.org/about/download] -> select 3 Subcellular Location Data
Downloaded from database. Columns containing the Gene name, reliability, and GO localization were parsed. Transmembrane proteins were pulled by "Plasma membrane" while secreted proteins were pulled by "Cell Junctions|Vesicles". Reliability scores[3] were converted to numbers 1 - 4, to compare to other sources. 





