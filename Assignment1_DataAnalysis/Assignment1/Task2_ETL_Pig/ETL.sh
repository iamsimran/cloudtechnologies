#execute this script to get the data into master node and
#then distributing it to worker node using hdfs put command


#following commands download data files from google drive along with other necessary jars
cd ~
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1ofnZhU4itz3OUbhjmkBFe4jlruyy6ov_' -O ~/StackExData1.csv
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1eVwW4_fVCvcO0wHKyXFFDbv51NpOoW4P' -O ~/StackExData2.csv
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1CGAwl-3UciP3bdBAMoeL_EuN0g6vudZn' -O ~/StackExData3.csv
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=175lAHp2uVurJf6FGp3y48th7Hahcr8hJ' -O ~/StackExData4.csv
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=10kW5VbQIPrtvNcJrRa4Za5VXYs1D1DHu' -O ~/parquet-pig-bundle-1.8.1.jar

wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1mTzCUL-iw7LLRAIAPKEb-zRlQI3DHPiL' -O ~/hadoop-streaming-1.2.1.jar
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1Tk4f6jQd5ZHq6IEYLRfQd2n6Bf-o1qqj' -O ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master.zip

#Main TFIDF Mapreduce code
unzip TF-IDF-implementation-using-map-reduce-Hadoop-python--master.zip

echo "Data files successfully downloaded!"

#moving data files to hdfs nodes
cd ~
hdfs dfs -mkdir /user/ETL/

hdfs dfs -put ~/StackExData*.* /user/ETL/
hdfs dfs -put ~/parquet-pig-bundle-1.8.1.jar /user/ETL/

hdfs dfs -chmod 777 /user/ETL/*

echo "Data files successfully uploaded to hadoop cluster."

#Creating pig script on the run and executing it for further ETL
cd ~
host=`hostname`
echo "REGISTER hdfs://$host/user/ETL/parquet-pig-bundle-1.8.1.jar" > Dataload.pig
cat ~/Assignment1/Task2_ETL_Pig/PigCommands.txt >> Dataload.pig
chmod 777 Dataload.pig
pig -f 'Dataload.pig'
