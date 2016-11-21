#!/bin/bash

# # Make a config change and need to modify a bunch of apps?

# # Set vars
PROJECT=project_id
ZONE=us-central1-f
MYSQL_INSTANCE=mysql1
export PROJECT
export ZONE
export MYSQL_INSTANCE
# get mysql ip address
output=$(gcloud sql instances describe $MYSQL_INSTANCE | grep ipAddress: )
mysql_ip=${output##-*:}
mysql_ip_trim="$(echo -e "${mysql_ip}" | tr -d '[[:space:]]')"
MYSQL_IP=$mysql_ip_trim
export MYSQL_IP
output=$(gcloud compute instances describe mongodb --zone $ZONE | grep natIP)
MONGO_IP="$(echo -e "${output}" | tr -d 'natIP:[[:space:]]')"
export MONGO_IP

# # API
eval envtpl < api/deployment.yml.tpl > api/deployment.yml
eval 'kubectl apply -f api/deployment.yml'
