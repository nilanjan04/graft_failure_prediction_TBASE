# Prediction of Long-term Graft Failures 

## Timelines: 
**Time of prediction:** 12 months post transplantation

**Duration of prediction:** 24 to 72 months post transplantation

## Execution steps
*To have the desired results, please execute the files in this order:*

**Step1:** Execute the SQL script (SQL_for_data_extraction.sql) and export the data in a CSV file. Please note the path in which you are saving the CSV.

**Step2:** To run the python scripts, first you need to install the required packages if not installed already. The python scripts has those istallation scripts in comments. Please uncomment and execute first. You may need to restart the kernel in case you are using Anaconda Spyder.
**Step2a:** If clustering should be considered, run the "Clustering - Create dataset" files first. Then run "Clustering - CoxRegression" and/or "Clustering - RandomForest".
**Step2b:** If clustering should not be considered, just run the "No clustering" files.

**Step3:** To import the dataset, please update the CSV path in the pd.readcsv line. After the dataset has been loaded as a pandas dataframe, you can execute the following codes as it is.

**Note:** In the code there are scripts which exports certain dataframes in a CSV file. Please update the path accordingly. 

