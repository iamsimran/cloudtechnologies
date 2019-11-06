set hive.cli.print.header=true;

--Creating table for Pig data
create external table IF NOT EXISTS StackExData (Id int, Score int, ViewCount int,
OwnerUserId int, OwnerDisplayName string, Body String)
row format delimited
fields terminated by ','
STORED AS parquet
LOCATION '/user/pig/StackExData/';

--Query 1: selecting top 10 posts by Score
select id,score,owneruserid from StackExData
where score is NOT NULL order by score desc limit 10;

--Query 2: selecting top 10 users by score
select owneruserid,sum(score) AS totalscore from StackExData
where OwnerUserId is not NULL
group by owneruserid order by totalscore desc limit 10;

--Query 3: Number of user who has used word "hadoop" in their posts
select count(distinct(owneruserid)) from StackExData where lower(body) like '%hadoop%';


--Just another query to fetch top 10 userid from query 2 for tfidf calculation
insert overwrite directory '/user/hive' select owneruserid from
  (select owneruserid,sum(score) AS totalscore from StackExData
  where owneruserid is not null group by owneruserid
  order by totalscore desc limit 10) as T;
