#!/bin/bash
# Starts Jenkins in a Docker container with Docker-in-Docker capability.
#
# Port 8080  - Jenkins web UI
# Port 50000 - Jenkins agent communication
# Volume jenkins_home - persists Jenkins data across restarts
# Docker socket mount - allows Jenkins to build Docker images on the host

CONTAINER_NAME="jenkins"
NETWORK_NAME="cicd-network"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '$CONTAINER_NAME' already exists."
    echo "To restart: docker start $CONTAINER_NAME"
    echo "To remove and recreate: docker rm -f $CONTAINER_NAME"
    exit 0
fi

docker run -d \
    --name "$CONTAINER_NAME" \
    --network "$NETWORK_NAME" \
    -p 8080:8080 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:lts

echo ""
echo "Jenkins is starting..."
echo "Web UI: http://localhost:8080"
echo ""
echo "To get the initial admin password, run:"
echo "  docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "Required plugins to install:"
echo "  - Pipeline"
echo "  - SonarQube Scanner"
echo "  - Docker Pipeline"
echo "  - Kubernetes Continuous Deploy"
