#!/bin/bash

EMAIL="piyumiwickramaarachchi1@gmail.com"

##Copy key file to remote server
sudo scp -o StrictHostKeyChecking=No -i key.pem /tmp/key.pem ec2-user@18.206.160.195:/tmp/

##Remote server task
sudo ssh -o StrictHostKeyChecking=No -i key.pem ec2-user@18.206.160.195 \
'sudo tar -czf /tmp/$(date +"%F_%T").tar.gz /var/log/httpd/access_log /var/log/httpd/error_log /var/www/html/index.html;\
sudo scp -o StrictHostKeyChecking=No -i key.pem /tmp/*.tar.gz ec2-user@54.175.169.61:/tmp/;\
sudo rm -rf /tmp/*.tar.gz;\
sudo rm -rf /tmp/key.pem'

##Copy file to S3 from local server
/usr/local/bin/aws s3 cp /tmp/*.tar.gz s3://s3bucketforbackup/

if [ $? -eq 0 ];then
   echo "Backup Completed Successfully"
   sudo rm -rf /tmp/*.tar.gz
else
   echo "Backup Failed"
   echo "Backup Failed" | mail -s "Amazon s3 Backup Status" $EMAIL
