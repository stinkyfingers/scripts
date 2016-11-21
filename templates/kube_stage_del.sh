#!/bin/bash

PROJECT=project_id
ZONE=us-central1-f
MYSQL_INSTANCE=mysql

export PROJECT
export ZONE
export MYSQL_INSTANCE

# # IPS
output=$(gcloud sql instances describe $MYSQL_INSTANCE | grep ipAddress: )
mysql_ip=${output##-*:}
mysql_ip_trim="$(echo -e "${mysql_ip}" | tr -d '[[:space:]]')"
MYSQL_IP=$mysql_ip_trim
export MYSQL_IP

output=$(gcloud compute instances describe mongodb --zone $ZONE | grep natIP)
MONGO_IP="$(echo -e "${output}" | tr -d 'natIP:[[:space:]]')"
export MONGO_IP

# # API
eval 'kubectl delete -f api/service.yml'
eval envtpl < api/deployment.yml.tpl > api/deployment.yml
eval 'kubectl delete -f api/deployment.yml'

# # Mongo
eval 'gcloud compute instances delete mongodb --zone $ZONE && y'

# # SQL
eval 'gcloud sql instances delete $MYSQL_INSTANCE && y'

# # Elasticsearch
eval 'kubectl delete -f elasticsearch/service.yml'
eval 'kubectl delete -f elasticsearch/deployment.yml'

# # Redis
eval 'kubectl delete -f redis/service.yml'
eval 'kubectl delete -f redis/deployment.yml'

# # Cluster
eval 'gcloud container clusters delete staging-1 --zone $ZONE'