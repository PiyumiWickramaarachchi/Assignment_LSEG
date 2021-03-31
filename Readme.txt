========Instructions to run script 1===========
Copy key.pem file into /tmp/ admin server
Put script1.sh into /tmp/  admin server 
Give the permission to script1.sh 
	#chmod +x /tmp/script2.sh

Use public IP address of web_server instead of "3.86.143.195"
Use your own email instead of "piyumiwickramaarachchi1@gmail.com"
Use your own RDS Endpoint instead of "database-1.cfk5li1pqpfc.us-east-1.rds.amazonaws.com"

Note: key.pem file is the downloaded key file when creating two EC2 instances. Both instances use this key file.

========Instructions to run script 2===========
Copy key.pem file into /tmp/ admin server
Put script2.sh into /tmp/ admin server 
Then give the permission to script2.sh 
	#chmod +x /tmp/script2.sh

Use public IP address of web_server instead of "18.206.160.195"
Use public IP address of admin server instead of "54.175.169.61"
Use your own email instead of "piyumiwickramaarachchi1@gmail.com"

Follow the below instructions, to run script2.sh daily.
	#echo "./script2.sh" > /etc/cron.daily/script2
	#chmod +x /etc/cron.daily/script2

Note: key.pem file is the downloaded key file when creating two EC2 instances. Both instances use this key file.