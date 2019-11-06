# creating directories to store results locally
mkdir ~/bodydata/
mkdir ~/finaldata

#creating table to store top terms for each user
hive -e "create external table topuserterms (userid int, toptenterms string) row format delimited fields terminated by ',';"

#looping through userid's to fetch their posts data and process them
for id in `hdfs dfs -cat /user/hive/000000_0`
do
        echo "Getting data from Hive for user id $id"
        #connecting hive to get the particular user's Data
        hive -e "select body from stackexdata where owneruserid=$id;" > ~/bodydata/$id.data
        if [ $? -eq 0 ]
        then
                echo "Data fetch for user $id successful"
        fi

        #replacing all html tags & non string characters from user's posts
        echo "Cleaning data for user $id..."
        sed -i 's/<[^>]*>/ /g' ~/bodydata/$id.data
        sed -i 's/[[:punct:]]/ /g' ~/bodydata/$id.data
        sed -i 's/[[:digit:]]//g' ~/bodydata/$id.data
        sed -i 's/[^[:alnum:]" "\t]//g' ~/bodydata/$id.data
        sed -i 's/"/ /g' ~/bodydata/$id.data
        sed -i "s/'/ /g" ~/bodydata/$id.data
        sed -i 's/\b\w\b \?//g' ~/bodydata/$id.data
        sed -i 's/\b\w\w\b \?//g' ~/bodydata/$id.data
        echo "Data Cleaned!"

        #dropping the data in hdfs to run the tfdif code on top of it
        hdfs dfs -mkdir /user/tfidfinput
        hdfs dfs -put ~/bodydata/$id.data /user/tfidfinput/

        # below is the main map reduce code for TFIDF on user's data
        echo "Initiating TFIDF calculation..."
        hadoop jar ~/hadoop-streaming-1.2.1.jar -input /user/tfidfinput/$id.data -output /user/tfidfinput/output4 -file ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper1.py -mapper ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper1.py -file ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/reducer1.py -reducer ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/reducer1.py

        hadoop jar ~/hadoop-streaming-1.2.1.jar -input /user/tfidfinput/output4/* -output /user/tfidfinput/output5 -file ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper2.py -mapper ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper2.py -file ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/reducer2.py -reducer ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/reducer2.py

        hadoop jar ~/hadoop-streaming-1.2.1.jar -input /user/tfidfinput/output5/* -output /user/tfidfinput/output6 -file ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper3.py -mapper ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper3.py -file ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/reducer3.py -reducer ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/reducer3.py

        hadoop jar ~/hadoop-streaming-1.2.1.jar -numReduceTasks 0 -input /user/tfidfinput/output6/* -output /user/tfidfinput/output7 -file ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper4.py -mapper ~/TF-IDF-implementation-using-map-reduce-Hadoop-python--master/mapper4.py

        #concatenating multiple files to generate one output file
        hdfs dfs -cat /user/tfidfinput/output7/part* > ~/$id.tfidf.data
        #removing all outout folders and making execution ready for next user data
        hdfs dfs -rm -r /user/tfidfinput/

        echo "TFIDF Calculated for user $id."

        #replacing the filenames in output data
        #then sorting the data based on TFIDF Scores to get the top 10 terms used by the user.
        host=`hostname`
        sed -i 's+hdfs://'"$host"'/user/tfidfinput/'"$id"'.data++g' ~/$id.tfidf.data
        cat ~/$id.tfidf.data|sort -k 2nr|head > ~/finaldata/$id.final.data
        tt=`cut -f1 ~/finaldata/$id.final.data|paste -s -d" "`

        hive -e "insert into topuserterms values ($id,'$tt');"

        echo "Top terms for user $id now available in hive table topuserterms."
done
