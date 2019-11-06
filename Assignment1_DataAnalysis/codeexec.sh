#unzip Assignment1.zip

chmod -R 777 Assignment1/
#downloading necessary datafiles and jars and executing Pig code
sh Assignment1/Task2_ETL_Pig/ETL.sh

#Executing Hive queries and extracting data for tfidf
hive -f "Assignment1/Task3_HiveDataAnalysis/HiveQueries.hql"

#Executing TFIDF code for top 10 users obtained from previous queries
sh Assignment1/Task4_TFIDF_TopTerms/TFIDF_TopTerms.sh

#Showing top 10 terms for each top 10 user
hive -e "set hive.cli.print.header=true; select * from topuserterms;"
