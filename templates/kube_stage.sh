#!/bin/bash

# # ./run.sh
# # todo firewall rules create (mysql?)
# # REMEMBER: push images to gcloud: gcloud docker push gcr.io/<project_id>/<image>


# # BEGIN
PROJECT=project_id
ZONE=us-central1-f
MYSQL_INSTANCE=mysql
export PROJECT
export ZONE
export MYSQL_INSTANCE

# # Installs
pip install envtpl

# # Set project and get credentials
eval "gcloud config set project $PROJECT"
eval 'gcloud container clusters create staging-1 --zone $ZONE'
eval 'gcloud container clusters get-credentials staging-1'

# # Elasticsearch
eval 'kubectl create -f elasticsearch/service.yml --namespace=elasticsearch'
eval 'kubectl create -f elasticsearch/service-account.yml'
eval 'kubectl create -f elasticsearch/deployment.yml'

# # Redis
eval 'kubectl create -f redis/service.yml --namespace=redis'
eval 'kubectl create -f redis/deployment.yml'

# # SQL
eval "gcloud sql instances create $MYSQL_INSTANCE --tier D4 && gcloud sql instances patch $MYSQL_INSTANCE --assign-ip && \
gcloud sql instances patch $MYSQL_INSTANCE --authorized-networks 0.0.0.0/0 && gcloud sql instances set-root-password $MYSQL_INSTANCE --password root"
# get mysql ip address
output=$(gcloud sql instances describe $MYSQL_INSTANCE | grep ipAddress: )
mysql_ip=${output##-*:}
mysql_ip_trim="$(echo -e "${mysql_ip}" | tr -d '[[:space:]]')"
MYSQL_IP=$mysql_ip_trim
export MYSQL_IP
#echo $MYSQL_IP
eval "mysqldump -d --host=200.200.13.13 --port=3306 -u root -p<pass> --all-databases > schemas.sql && mysql --host=$MYSQL_IP -u root -proot < schemas.sql"
rm schemas.sql

# # MongoDB 
eval "gcloud compute instances create mongodb \
  --image-family=container-vm --image-project=google-containers \
  --zone $ZONE \
  --machine-type g1-small"

eval 'gcloud compute ssh --zone $ZONE mongodb --command "sudo docker run -p 27017:27017 -d mongo"'

eval 'gcloud compute firewall-rules create default-mongo --allow tcp:27017 --source-ranges 0.0.0.0/0'

output=$(gcloud compute instances describe mongodb --zone $ZONE | grep natIP)
MONGO_IP="$(echo -e "${output}" | tr -d 'natIP:[[:space:]]')"
export MONGO_IP
# echo $MONGO_IP

# # API
eval 'kubectl create -f api/service.yml --namespace=api'
eval envtpl < api/deployment.yml.tpl > api/deployment.yml
eval 'kubectl create -f api/deployment.yml'

# # END
echo 'DONE'
