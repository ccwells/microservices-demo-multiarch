#!/bin/bash

echo "Starting..."
## Start Minikube
echo "> Creation of Minikube"
minikube start --cpus=4 --memory 8192 
kubectl create secret generic datadog-secret --from-literal=api-key=$DD_API_KEY --from-literal=app-key=$DD_APP_KEY
## Reconfigure agent
echo "> Setting up of datadog-agent"
helm install datadog-agent -f dash/datadog-values.yaml datadog/datadog --set datadog.apiKey=$DD_API_KEY
## Restart kubernetes Deployment and Services
echo "> (Building) Running micro-services"

# Set context to docker
eval $(minikube -p minikube docker-env)
# Pull all missing images
docker pull redis:alpine
docker pull mariadb
docker pull busybox:latest
docker pull ddtraining/attackbox:2.1.3

# Skaffold build and run
## Loop until return code success
skaffold build --platform=linux/amd64
until [ $? -eq 0 ]; do skaffold build --platform=linux/amd64; done
skaffold run --platform=linux/amd64

echo "> Configuring extras"
# Setting variable to check agent status
export AGENT_POD=$(kubectl get pods | sed -e '/datadog-agent/!d' | sed -n '/cluster/!p' | sed -n '/metrics/!p' | awk -F' ' '{print $1}')
# Configure nginx
export FRONTEND_LB=$(minikube service frontend-lb --url)
sudo -E ./dash/microservices/conf_nginx.sh