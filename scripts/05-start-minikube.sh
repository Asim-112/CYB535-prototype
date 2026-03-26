#!/bin/bash
# Starts a local Kubernetes cluster using Minikube.
# Minikube must be installed before running this script.
#
# Install Minikube:
#   Windows: winget install minikube
#   macOS:   brew install minikube
#   Linux:   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
#            && sudo install minikube-linux-amd64 /usr/local/bin/minikube

echo "Starting Minikube cluster..."
minikube start

echo ""
echo "Cluster status:"
kubectl get nodes

echo ""
echo "To access the dashboard:"
echo "  minikube dashboard"
