## Create the cluster
gcloud container clusters create dpn-swagstore-stdcluster \ 
  --enable-autoupgrade \ 
  --enable-autoscaling \ 
  --min-nodes=3 --max-nodes=10 --num-nodes=3 \ 
  --zone=us-east1 \ 
  --project=datadog-sandbox \ 
  --labels=team=dpn-ops,creator=charlie-wells,env=demo,app=swagstore  \
  --enable-ip-alias \ 
  --create-subnetwork name=dpn-subnet-2

## Get the cluster credentials
gcloud container clusters get-credentials datadog-swagstore-stdcluster \ 
--location=us-east1 --project=datadog-sandbox

## Create a secret to hold the API & APP keys
kubectl create secret generic dpn-998814-secret --from-literal api-key=$DD_API_KEY --from-literal app-key=$DD_APP_KEY

## Install Helm repo (one-time only)
helm repo add datadog https://helm.datadoghq.com (one-time only)
helm repo update

## Install the Datadog Agent using Helm
helm install datadog-agent -f ./values.yaml --set targetSystem=linux --set datadog.kubeStateMetricsEnabled=false datadog/datadog

## Verify Datadog Agent is installed and running
kubectl get pods | grep agent

## [Bonus] To verify the Node Agent has successfully connected to the Cluster Agent:
kubectl exec -it <AGENT_POD_NAME> -- agent status

## To uninstall DD agent:
helm uninstall datadog-agent

## To modify DD agent’s configurations:
helm upgrade -f ../Downloads/values.yaml datadog-agent datadog/datadog

## Additional DD agent configurations (Ref):
## To collect cluster’s metrics as well:
gcloud container clusters update dpn-swagstore-stdcluster --location=us-east1 --monitoring=SYSTEM,API_SERVER,SCHEDULER,CONTROLLER_MANAGER

## Create GCP Artifact repository
gcloud artifacts repositories create dpn-repo-multiarch --repository-format=docker --location=us-east1 --labels=team=dpn-ops,creator=charlie-wells,env=demo,app=swagstore

## Create ingress to allow external access to our swagstore
kubectl apply -f ingress.yaml

## Build and deploy the application
skaffold run -p gcb --default-repo  us-east1-docker.pkg.dev/datadog-sandbox/dpn-repo-multiarch --platform=linux/amd64

## To get the public IP address of frontend service:
kubectl get service frontend-external
