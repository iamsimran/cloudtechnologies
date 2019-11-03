# cloudtechnologies
Repository to store code related stack exchange dataset

# Task 1:
This repository has the dataset files downloaded from stackexchaneg query engine and has top 200,000 records based on post viewcount. Data is split up into 4 files with 50,000 records each.

StackExData1.csv  
StackExData2.csv  
StackExData3.csv  
StackExData4.csv

# Task 2:

This folder contains ETL code to be executed in Pig. The .pig script will load the above 4 files to 4 different variables. These will then be merged into a single variable and then will be stored in HDFS after selecting only required columns.  
Source files are read using CSVExcelStorage class which is suitable to read data which has delimiters and multilines withing the data itself. The headers for each file is skipped.  
The merged and selected data is finally stored in Parquet format which is mostly commonly used for text/csv data. Parquet files are very well handled in Hive system.

# Task 3:

Extract data from PIG after ETL operations stored in HDFS is then used to create an external Hive table on top of it.  
Following 3 queries are triggered to get the results:

1. To find top 10 posts with scores  
2. To find top 10 users with highest post scores  
3. Number of users who used word 'hadoop' in their posts

# Task 4:
This task achieves the TFIDF part in which top 10 used terms used by each of the top 10 users is calculated. The base code is in python and it executes the code in mapreduce to achieve its target.
