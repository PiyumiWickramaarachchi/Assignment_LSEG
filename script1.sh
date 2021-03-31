#!/bin/bash

WEB_SERVER_IP="3.86.143.195"
EMAIL="piyumiwickramaarachchi1@gmail.com"

MYSQL_ENDPOINT="database-1.cfk5li1pqpfc.us-east-1.rds.amazonaws.com"
MYSQL_USER="admin"
MYSQL_PASSWORD="mysql2021"
DBNAME="RESULT_DB"
TABLE="RESULT_TB"

timestamp=$(date +"%F %r")
serverstate="/tmp/runOrnot"
contentstate="/tmp/diffOreq"

##Check the web_server up and running
ssh -o StrictHostKeyChecking=No -i key.pem ec2-user@$WEB_SERVER_IP 'ps -C httpd > /dev/null'

if [ $? -eq 0 ];then
        echo "Alredy httpd started" > $serverstate
else
        echo "httpd not start" >  $serverstate
        ssh -o StrictHostKeyChecking=No -i key.pem ec2-user@$WEB_SERVER_IP 'sudo systemctl start httpd'
fi

##Check the Content of web server##
curl http://3.86.143.195 > /tmp/current
echo "Hello World" > /tmp/original

if diff /tmp/current /tmp/original > /dev/null 2>&1
then
  echo "equal content" > $contentstate
else
  echo "different content" > $contentstate
fi

sudo rm -rf /tmp/current /tmp/original


##Create DB##

mysql -h $MYSQL_ENDPOINT -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE $DBNAME;" 2> /tmp/error1

if [ $? -eq 0 ];
then
    echo "Database '$DBNAME' is created"
elif (grep -i "^ERROR 1007" /tmp/error1 > /dev/null);
then
    echo "Database '$DBNAME' already exists"
else
    echo "Failed to create database '$DBNAME'"
    echo "Failed to create database" | mail -s "DB Creation Failed" $EMAIL
fi

rm -r /tmp/error1

##Create Table##

mysql -h $MYSQL_ENDPOINT -u$MYSQL_USER -p$MYSQL_PASSWORD -e "use $DBNAME;\
create table $TABLE(id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,\
cur_timestamp TIMESTAMP(6),\
run_state VARCHAR(100) NOT NULL,\
content_state VARCHAR(100) NOT NULL);" 2> /tmp/error1

if [ $? -eq 0 ];
then
    echo "$TABLE Table is created"
elif (grep -i "^ERROR 1050" /tmp/error1 > /dev/null);
then
    echo "Table already exists"
else
    echo "Failed to create $TABLE table"
    echo "Failed to create table" | mail -s "Table Creation Failed" $EMAIL
fi

rm -r /tmp/error1

##Data Insert##

VAR1=$(cat $serverstate)
VAR2=$(cat $contentstate)

mysql -h $MYSQL_ENDPOINT -u$MYSQL_USER -p$MYSQL_PASSWORD <<EOF
use $DBNAME;
insert into $TABLE (\`cur_timestamp\`, \`run_state\`, \`content_state\`) VALUES ("$timestamp", "$VAR1", "$VAR2");
select * from $TABLE;
EOF

if [ $? -eq 0 ];
then
    echo "++++++++++++++++++++++++++++++++++"
    echo "+++Successfully inserted record+++"
    echo "++++++++++++++++++++++++++++++++++"
else
    echo "Failed to insert data"
    echo "Failed to insert data" | mail -s "Failed to insert data" $EMAIL
fi