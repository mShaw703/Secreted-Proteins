First need to pull location data from different databases. 
For Compartments: http://compartments.jensenlab.org/Downloads use the knowledge channel, humans
For Protein Atlas: http://www.proteinatlas.org/about/download use the Subcellular Location Data
For LOCATE: http://locate.imb.uq.edu.au/downloads.shtml use the Homo sapiens Locate dataset.

When going through Compartments dataset, there were several terms that may have been referring to a secreted protein. Filtered through the terms and narrowed it down to a few to compile a list of possible secreted proteins.
Terms used for compartments: 'Vesicle', 'Secretory', 'Extracellular'. 'Golgi' and 'ER' were also used but after review of the terms that came from searching the two key words; 'ER to Golgi' was determined to be the best possible search term.

When going through data from the Protein Atlas data base. Data was recieved from website as a CSV file. Had to be converted to XLS and then read into R studio as a excel spreadsheet because the computer wouldnt trust the csv file from the internet. Protein Atlas gives their results a reliabilty score. I extracted only the validated genes in this case however supported may also be a good option. My reasoning was base off the definition for each score given here -> http://www.proteinatlas.org/about/assays+annotation. Removed several other columns in file that either did not include data or that had irrelevant data to the project. 

Once a data frame was created that contained all the well supported locations, began filtering through terms as was done with the compartments data base, trying to follow a similar pattern. Start by filtering for Cell Junctions and Vesicles. Only two terms used for this database. Combined the two subsets and removed repeats to get a final list of secreted proteins.

#########

Now the two data sets can be compared to see if there are any duplicates between them. Also want to cross check to see if the terms used to find possible secreted proteins in Compartments is valid. 

First had to edit both sets so the column names matched. Began with "Identifyer"; it was the same for both sets giving the 'ENSG#. The second column is labeled "Gene Name" and is the same in both sets. The last two columns are "GO#" and "Location". An additional column was added stating the database used. 
