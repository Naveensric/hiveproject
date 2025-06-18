#!/bin/bash

# Create the following table in mysql db
sqoop eval --connect jdbc:mysql://quickstart.cloudera:3306/retail_db --username root --password cloudera --query "create table naveen_daily_prices (customer_id	 int(11),store_id	 int(11),first_name	 varchar(45),last_name	 varchar(45),email	 varchar(45),address_id	 int(11),active	 varchar(45),create_date	date,last_update	date)"

# verify source table is created successfully
sqoop eval --connect jdbc:mysql://quickstart.cloudera:3306/retail_db --username root --password cloudera --query "describe naveen_daily_prices"

# Import naveen data to the sourec table
sqoop eval --connect jdbc:mysql://quickstart.cloudera:3306/retail_db --username root --password cloudera --query "load data local infile '/home/cloudera/naveen/customers.csv' into table naveen_daily_prices fields terminated by ','"

# verify data successfully loaded into source table
sqoop eval --connect jdbc:mysql://quickstart.cloudera:3306/retail_db --username root --password cloudera --query "select * from naveen_daily_prices  limit 10"

# sqoop import: Import mysql data from source table to hive
sqoop import --connect jdbc:mysql://quickstart.cloudera:3306/retail_db --username root --password cloudera --table naveen_daily_prices --hive-database june14 --hive-import --fields-terminated-by ',' --m 1

# Create the result table in hive
hive -e "create table june14.naveen_daily_prices as select store_id ,sum(store_id) total_store from june14.naveen_daily_prices group by store_id;"

# Verify the result table in hive
hive -e "select * from june14.naveen_daily_prices limit 10;"

# sqoop export data from HDFS to mysql output table
sqoop export --connect jdbc:mysql://quickstart.cloudera:3306/naveen --username root --password cloudera --table naveen_daily_prices --export-dir /user/hive/warehouse/master/naveen_daily --input-fields-terminated-by ','

# validate data is sucessfully exported in mysql
sqoop eval --connect jdbc:mysql://quickstart.cloudera:3306/naveen --username root --password cloudera --query "select * from naveen_daily limit 10"
