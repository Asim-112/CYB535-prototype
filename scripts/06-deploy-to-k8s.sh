#!/bin/bash
# Deploys the Java application to the Kubernetes cluster.
# Applies the Deployment (2 replicas) and Service (NodePort 30080).
#
# Prerequisites:
#   - Minikube is running (scripts/05-start-minikube.sh)
#   - Docker image has been pushed to Docker Hub

MANIFEST="../deployment.yaml"

echo "Applying Kubernetes manifests..."
kubectl apply -f "$MANIFEST"

echo ""
echo "Waiting for deployment rollout..."
kubectl rollout status deployment/java-app

echo ""
echo "Pod status:"
kubectl get pods -l app=java-app

echo ""
echo "Service details:"
kubectl get svc java-app-service

echo ""
echo "Access the application:"
minikube service java-app-service --url
